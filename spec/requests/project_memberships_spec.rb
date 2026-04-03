require "rails_helper"

RSpec.describe "ProjectMemberships", type: :request do
  let(:project) { create(:project) }
  let(:manager) { create(:user, :project_manager) }
  let(:member) { create(:user) }
  let(:new_user) { create(:user) }
  let(:outsider) { create(:user) }

  before do
    create(:project_membership, :manager, project: project, user: manager)
    create(:project_membership, project: project, user: member)
  end

  describe "GET /projects/:id/memberships" do
    it "lists members" do
      sign_in manager

      get project_memberships_path(project)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(manager.email)
      expect(response.body).to include(member.email)
    end

    it "redirects unauthenticated user" do
      get project_memberships_path(project)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "blocks unauthorized member" do
      sign_in member

      get project_memberships_path(project)

      expect(response).to redirect_to(root_path)
    end

    it "blocks outsider not in policy scope" do
      sign_in outsider

      get project_memberships_path(project)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /projects/:id/memberships" do
    it "adds member" do
      sign_in manager

      expect do
        post project_memberships_path(project), params: { project_membership: { user_id: new_user.id, role: "member" } }
      end.to change(ProjectMembership, :count).by(1)

      expect(response).to redirect_to(settings_project_path(project))
    end

    it "returns validation error for duplicate membership" do
      sign_in manager

      expect do
        post project_memberships_path(project), params: { project_membership: { user_id: member.id, role: "member" } }
      end.not_to change(ProjectMembership, :count)

      expect(response).to redirect_to(settings_project_path(project))
      expect(flash[:alert]).to be_present
    end

    it "blocks unauthorized member" do
      sign_in member

      post project_memberships_path(project), params: { project_membership: { user_id: new_user.id, role: "member" } }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE /projects/:id/memberships/:id" do
    let!(:membership) { create(:project_membership, project: project, user: new_user) }

    it "removes member" do
      sign_in manager

      expect do
        delete project_membership_path(project, membership)
      end.to change(ProjectMembership, :count).by(-1)

      expect(response).to redirect_to(settings_project_path(project))
    end

    it "blocks unauthorized member" do
      sign_in member

      expect do
        delete project_membership_path(project, membership)
      end.not_to change(ProjectMembership, :count)

      expect(response).to redirect_to(root_path)
    end
  end
end
