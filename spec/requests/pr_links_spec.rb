require "rails_helper"

RSpec.describe "PrLinks", type: :request do
  let(:project) { create(:project) }
  let(:author) { create(:user) }
  let(:member) { create(:user) }
  let(:outsider) { create(:user) }
  let(:ticket) { create(:ticket, project: project, reporter: author, assignee: member) }

  before do
    create(:project_membership, project: project, user: author)
    create(:project_membership, project: project, user: member)
  end

  describe "POST /tickets/:id/pr_links" do
    let(:valid_params) do
      { pr_link: { title: "Fix auth", url: "https://github.com/acme/app/pull/123", status: "open" } }
    end

    it "creates a PR link" do
      sign_in member

      expect do
        post ticket_pr_links_path(ticket), params: valid_params
      end.to change(PrLink, :count).by(1)

      expect(response).to redirect_to(ticket_path(ticket))
      expect(PrLink.last.user).to eq(member)
    end

    it "returns validation errors for invalid params" do
      sign_in member

      expect do
        post ticket_pr_links_path(ticket), params: { pr_link: { title: "", url: "bad" } }
      end.not_to change(PrLink, :count)

      expect(response).to redirect_to(ticket_path(ticket))
      expect(flash[:alert]).to be_present
    end

    it "blocks unauthorized users" do
      sign_in outsider

      post ticket_pr_links_path(ticket), params: valid_params

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /tickets/:id/pr_links/:id" do
    let!(:pr_link) { create(:pr_link, ticket: ticket, user: author) }

    it "deletes PR link for owner" do
      sign_in author

      expect do
        delete ticket_pr_link_path(ticket, pr_link)
      end.to change(PrLink, :count).by(-1)

      expect(response).to redirect_to(ticket_path(ticket))
    end

    it "blocks non-owner non-admin" do
      sign_in member

      expect do
        delete ticket_pr_link_path(ticket, pr_link)
      end.not_to change(PrLink, :count)

      expect(response).to redirect_to(root_path)
    end
  end
end
