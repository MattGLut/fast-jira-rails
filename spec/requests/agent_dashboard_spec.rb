require "rails_helper"

RSpec.describe "AgentDashboard", type: :request do
  let(:project) { create(:project) }
  let(:agent_user) { create(:user, first_name: "Claude", last_name: "Agent") }
  let(:api_token) { create(:api_token, name: "Claude AI Agent", user: agent_user, last_used_at: 30.minutes.ago) }
  let(:assigned_ticket) do
    create(:ticket, project: project, assignee: agent_user, reporter: agent_user, status: :in_progress, title: "Build notifications dropdown UX")
  end

  before do
    create(:comment, :agent_authored, user: agent_user, ticket: assigned_ticket, body: "Working on this now")
    create(:pr_link, user: agent_user, ticket: assigned_ticket, title: "Notifications UX PR")
    api_token
  end

  describe "GET /agents" do
    it "returns 200 for authenticated admin" do
      sign_in create(:user, :admin)

      get agents_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Claude AI Agent")
    end

    it "returns 200 for authenticated developer" do
      sign_in create(:user)

      get agents_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Claude AI Agent")
    end

    it "redirects to login when not authenticated" do
      get agents_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /agents/:id" do
    it "returns 200 for valid token ID" do
      sign_in create(:user)

      get agent_path(api_token)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Claude AI Agent")
    end

    it "shows agent activity timeline" do
      sign_in create(:user)
      create(:comment, :agent_authored, user: agent_user, ticket: assigned_ticket, body: "Timeline comment")
      create(:activity_log, user: agent_user, ticket: assigned_ticket, action: "status_changed")

      get agent_path(api_token)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Activity Timeline")
      expect(response.body).to include(assigned_ticket.title)
    end

    it "shows agent statistics" do
      sign_in create(:user)

      get agent_path(api_token)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Total assigned")
      expect(response.body).to include("Completed")
    end

    it "returns 404 for non-existent token" do
      sign_in create(:user)

      get agent_path(id: 99_999)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /agents (with activity data)" do
    it "shows summary statistics" do
      sign_in create(:user)

      get agents_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Active agents")
      expect(response.body).to include("Tickets in progress")
    end
  end
end
