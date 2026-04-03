require "rails_helper"

RSpec.describe "Tickets reorder", type: :request do
  let(:manager) { create(:user, :project_manager) }
  let(:member) { create(:user) }
  let(:project) { create(:project) }

  before do
    create(:project_membership, :manager, project: project, user: manager)
    create(:project_membership, project: project, user: member)
  end

  describe "PATCH /tickets/:id/reorder" do
    it "updates status and position when moving across columns" do
      sign_in manager
      ticket = create(:ticket, project: project, reporter: manager, status: :todo)
      ticket.update_column(:position, 1)
      existing = create(:ticket, project: project, reporter: manager, status: :in_progress)
      existing.update_column(:position, 0)

      patch reorder_ticket_path(ticket),
            params: { status: "in_progress", position: 0 },
            as: :json

      expect(response).to have_http_status(:ok)
      expect(ticket.reload).to have_attributes(status: "in_progress", position: 0)
      expect(existing.reload.position).to eq(1)
    end

    it "updates only position within the same column" do
      sign_in manager
      first = create(:ticket, project: project, reporter: manager, status: :todo, position: 0)
      second = create(:ticket, project: project, reporter: manager, status: :todo, position: 1)
      third = create(:ticket, project: project, reporter: manager, status: :todo, position: 2)

      patch reorder_ticket_path(third),
            params: { status: "todo", position: 1 },
            as: :json

      expect(response).to have_http_status(:ok)
      expect(first.reload.position).to eq(0)
      expect(third.reload.position).to eq(1)
      expect(second.reload.position).to eq(2)
    end

    it "returns 401 for unauthenticated requests" do
      ticket = create(:ticket, project: project, reporter: manager, status: :todo)

      patch reorder_ticket_path(ticket),
            params: { status: "in_progress", position: 0 },
            as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it "repositions sibling tickets correctly" do
      sign_in manager
      first = create(:ticket, project: project, reporter: manager, status: :todo, position: 0)
      second = create(:ticket, project: project, reporter: manager, status: :todo, position: 1)
      third = create(:ticket, project: project, reporter: manager, status: :todo, position: 2)

      patch reorder_ticket_path(first),
            params: { status: "todo", position: 2 },
            as: :json

      expect(response).to have_http_status(:ok)
      expect(second.reload.position).to eq(0)
      expect(third.reload.position).to eq(1)
      expect(first.reload.position).to eq(2)
    end

    it "returns error for invalid status" do
      sign_in manager
      ticket = create(:ticket, project: project, reporter: manager, status: :todo)

      patch reorder_ticket_path(ticket),
            params: { status: "not_a_status", position: 0 },
            as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to include("error" => "Invalid status")
    end
  end
end
