require "rails_helper"

RSpec.describe "Labels", type: :request do
  let(:project) { create(:project) }
  let(:manager) { create(:user, :project_manager) }
  let(:member) { create(:user) }
  let(:outsider) { create(:user) }
  let!(:label) { create(:label, project: project, name: "backend") }

  before do
    create(:project_membership, :manager, project: project, user: manager)
    create(:project_membership, project: project, user: member)
  end

  describe "GET /projects/:id/labels" do
    it "lists labels" do
      sign_in member

      get project_labels_path(project)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Labels")
      expect(response.body).to include("backend")
    end

    it "redirects unauthenticated user" do
      get project_labels_path(project)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "blocks non-member access" do
      sign_in outsider

      get project_labels_path(project)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /projects/:id/labels" do
    it "creates label" do
      sign_in manager

      expect do
        post project_labels_path(project), params: { label: { name: "frontend", color: "#22C55E" } }
      end.to change(Label, :count).by(1)

      expect(response).to redirect_to(settings_project_path(project))
    end

    it "returns validation failure for invalid params" do
      sign_in manager

      expect do
        post project_labels_path(project), params: { label: { name: "", color: "bad" } }
      end.not_to change(Label, :count)

      expect(response).to redirect_to(settings_project_path(project))
      expect(flash[:alert]).to be_present
    end

    it "blocks unauthorized user" do
      sign_in member

      post project_labels_path(project), params: { label: { name: "frontend", color: "#22C55E" } }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /projects/:id/labels/:id" do
    it "updates label" do
      sign_in manager

      patch project_label_path(project, label), params: { label: { name: "api" } }

      expect(response).to redirect_to(settings_project_path(project))
      expect(label.reload.name).to eq("api")
    end

    it "returns validation failure for invalid params" do
      sign_in manager

      patch project_label_path(project, label), params: { label: { color: "invalid" } }

      expect(response).to redirect_to(settings_project_path(project))
      expect(flash[:alert]).to be_present
      expect(label.reload.color).not_to eq("invalid")
    end
  end

  describe "DELETE /projects/:id/labels/:id" do
    it "destroys label" do
      sign_in manager

      expect do
        delete project_label_path(project, label)
      end.to change(Label, :count).by(-1)

      expect(response).to redirect_to(settings_project_path(project))
    end

    it "blocks unauthorized user" do
      sign_in member

      expect do
        delete project_label_path(project, label)
      end.not_to change(Label, :count)

      expect(response).to redirect_to(root_path)
    end
  end
end
