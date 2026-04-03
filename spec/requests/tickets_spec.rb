require "rails_helper"

RSpec.describe "Tickets", type: :request do
  let(:manager) { create(:user, :project_manager) }
  let(:member) { create(:user) }
  let(:other_member) { create(:user) }
  let(:outsider) { create(:user) }
  let(:project) { create(:project) }
  let(:ticket) { create(:ticket, project: project, reporter: manager, assignee: member, title: "Main ticket") }

  before do
    create(:project_membership, :manager, project: project, user: manager)
    create(:project_membership, project: project, user: member)
    create(:project_membership, project: project, user: other_member)
  end

  describe "GET /tickets/:id" do
    before do
      create(:comment, ticket: ticket, user: member, body: "Ship it")
      create(:activity_log, ticket: ticket, user: manager, action: "updated")
      create(:pr_link, ticket: ticket, user: member, title: "PR 42")
    end

    it "shows ticket with comments, activity, and PR links" do
      sign_in member

      get ticket_path(ticket)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Main ticket")
      expect(response.body).to include("Comments")
      expect(response.body).to include("Activity")
      expect(response.body).to include("PR 42")
    end

    it "redirects unauthenticated user" do
      get ticket_path(ticket)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "denies users outside policy scope" do
      sign_in outsider

      get ticket_path(ticket)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /projects/:id/tickets/new" do
    it "shows new ticket form" do
      sign_in member

      get new_project_ticket_path(project)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Create Ticket")
    end
  end

  describe "POST /projects/:id/tickets" do
    let(:valid_params) do
      {
        ticket: {
          title: "New Bug",
          description: "Investigate bug",
          priority: "high",
          ticket_type: "bug",
          story_points: nil,
          due_date: Date.current.to_s
        }
      }
    end

    it "creates ticket and sets reporter to current user" do
      sign_in member

      expect do
        post project_tickets_path(project), params: valid_params
      end.to change(Ticket, :count).by(1)

      created = Ticket.order(:id).last
      expect(created.reporter).to eq(member)
      expect(response).to redirect_to(ticket_path(created))
    end

    it "returns validation errors for invalid params" do
      sign_in member

      expect do
        post project_tickets_path(project), params: { ticket: { title: "" } }
      end.not_to change(Ticket, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /tickets/:id/edit" do
    it "shows edit form" do
      sign_in member

      get edit_ticket_path(ticket)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Edit Ticket")
    end
  end

  describe "PATCH /tickets/:id" do
    it "updates ticket" do
      sign_in member

      patch ticket_path(ticket), params: { ticket: { title: "Retitled" } }

      expect(response).to redirect_to(ticket_path(ticket))
      expect(ticket.reload.title).to eq("Retitled")
    end

    it "returns validation errors for invalid params" do
      sign_in member

      patch ticket_path(ticket), params: { ticket: { title: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(ticket.reload.title).to eq("Main ticket")
    end
  end

  describe "DELETE /tickets/:id" do
    it "destroys ticket for manager" do
      sign_in manager
      ticket

      expect do
        delete ticket_path(ticket)
      end.to change(Ticket, :count).by(-1)

      expect(response).to redirect_to(board_project_path(project))
    end

    it "blocks non-manager non-admin users" do
      sign_in other_member
      ticket

      expect do
        delete ticket_path(ticket)
      end.not_to change(Ticket, :count)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /tickets/:id/transition" do
    it "changes status and creates activity log" do
      sign_in member

      expect do
        patch transition_ticket_path(ticket), params: { status: "in_progress" }
      end.to change(ActivityLog, :count).by(1)

      expect(response).to redirect_to(board_project_path(project))
      expect(ticket.reload.status).to eq("in_progress")
      expect(ActivityLog.last.action).to eq("status_changed")
    end
  end

  describe "PATCH /tickets/:id/assign" do
    it "assigns user and creates activity log" do
      sign_in manager

      expect do
        patch assign_ticket_path(ticket), params: { assignee_id: other_member.id }
      end.to change(ActivityLog, :count).by(1)

      expect(response).to redirect_to(ticket_path(ticket))
      expect(ticket.reload.assignee).to eq(other_member)
      expect(ActivityLog.last.action).to eq("assignee_changed")
    end
  end

  describe "GET /my_tickets" do
    let(:admin_user) { create(:user, :admin) }
    let!(:my_ticket) { create(:ticket, project: project, assignee: admin_user, reporter: manager, title: "Mine") }
    let!(:someone_else_ticket) { create(:ticket, project: project, assignee: other_member, title: "Not mine") }

    it "shows current user assigned tickets" do
      sign_in admin_user

      get my_tickets_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("My Tickets")
      expect(response.body).to include(my_ticket.title)
      expect(response.body).not_to include("Not mine")
    end

    it "redirects unauthenticated user" do
      get my_tickets_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
