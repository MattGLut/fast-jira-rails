require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:user) { create(:user) }

  describe "GET /" do
    let(:project) { create(:project) }
    let!(:assigned_ticket) { create(:ticket, project: project, assignee: user, reporter: user, status: :todo, title: "Assigned Work") }
    let!(:other_ticket) { create(:ticket, project: project, status: :in_progress, title: "Other Work") }

    before do
      create(:project_membership, project: project, user: user)
    end

    it "renders dashboard for authenticated user" do
      sign_in user

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Dashboard")
    end

    it "redirects to login for unauthenticated user" do
      get root_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "shows ticket stats and assigned tickets" do
      sign_in user

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Assigned to me")
      expect(response.body).to include("Assigned Work")
      expect(response.body).to include(project.key)
    end
  end
end
