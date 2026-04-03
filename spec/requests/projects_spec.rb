require "rails_helper"

RSpec.describe "Projects", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:manager) { create(:user, :project_manager) }
  let(:member) { create(:user) }
  let(:outsider) { create(:user) }
  let(:project) { create(:project, name: "Alpha") }

  before do
    create(:project_membership, :manager, project: project, user: manager)
    create(:project_membership, project: project, user: member)
  end

  describe "GET /projects" do
    let!(:visible_project) { project }
    let!(:hidden_project) { create(:project, name: "Hidden") }

    it "lists projects in policy scope" do
      sign_in member

      get projects_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Alpha")
      expect(response.body).not_to include("Hidden")
    end

    it "redirects unauthenticated user to login" do
      get projects_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /projects/:id" do
    it "shows the project for authorized user" do
      sign_in member

      get project_path(project)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(project.name)
    end

    it "does not allow users outside policy scope" do
      sign_in outsider

      get project_path(project)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /projects/new" do
    it "shows new form for admin" do
      sign_in admin

      get new_project_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Create Project")
    end

    it "shows new form for project manager" do
      sign_in manager

      get new_project_path

      expect(response).to have_http_status(:ok)
    end

    it "blocks unauthorized user" do
      sign_in member

      get new_project_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end
  end

  describe "POST /projects" do
    let(:valid_params) do
      { project: { name: "Platform", key: "PLAT", description: "Core platform" } }
    end
    let(:invalid_params) do
      { project: { name: "", key: "bad", description: "Invalid" } }
    end

    it "creates a project with valid params" do
      sign_in admin

      expect do
        post projects_path, params: valid_params
      end.to change(Project, :count).by(1)

      created_project = Project.order(:id).last
      expect(response).to redirect_to(board_project_path(created_project))
      expect(created_project.project_memberships.find_by(user: admin)&.role).to eq("manager")
    end

    it "renders errors for invalid params" do
      sign_in admin

      expect do
        post projects_path, params: invalid_params
      end.not_to change(Project, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "blocks unauthorized user" do
      sign_in member

      post projects_path, params: valid_params

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /projects/:id/edit" do
    it "shows edit form for project manager" do
      sign_in manager

      get edit_project_path(project)

      expect(response).to have_http_status(:ok)
    end

    it "blocks regular project member" do
      sign_in member

      get edit_project_path(project)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /projects/:id" do
    it "updates project" do
      sign_in manager

      patch project_path(project), params: { project: { name: "Renamed" } }

      expect(response).to redirect_to(project_path(project))
      expect(project.reload.name).to eq("Renamed")
    end

    it "returns validation errors for invalid params" do
      sign_in manager

      patch project_path(project), params: { project: { key: "x" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(project.reload.key).not_to eq("x")
    end
  end

  describe "DELETE /projects/:id" do
    it "destroys project for admin" do
      sign_in admin

      expect do
        delete project_path(project)
      end.to change(Project, :count).by(-1)

      expect(response).to redirect_to(projects_path)
    end

    it "blocks non-admin users" do
      sign_in manager

      expect do
        delete project_path(project)
      end.not_to change(Project, :count)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /projects/:id/board" do
    let!(:todo_ticket) { create(:ticket, project: project, status: :todo, title: "To do") }
    let!(:done_ticket) { create(:ticket, project: project, status: :done, title: "Done") }

    it "renders kanban board with tickets grouped by status" do
      sign_in member

      get board_project_path(project)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Board")
      expect(response.body).to include("To do")
      expect(response.body).to include("Done")
    end

    it "redirects unauthenticated user" do
      get board_project_path(project)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /projects/:id/settings" do
    it "renders settings page for manager" do
      sign_in manager

      get settings_project_path(project)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Project Settings")
    end

    it "blocks unauthorized member" do
      sign_in member

      get settings_project_path(project)

      expect(response).to redirect_to(root_path)
    end
  end
end
