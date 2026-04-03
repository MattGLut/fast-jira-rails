require "rails_helper"

RSpec.describe "Comments", type: :request do
  let(:project) { create(:project) }
  let(:author) { create(:user) }
  let(:member) { create(:user) }
  let(:outsider) { create(:user) }
  let(:ticket) { create(:ticket, project: project, reporter: author, assignee: member) }

  before do
    create(:project_membership, project: project, user: author)
    create(:project_membership, project: project, user: member)
  end

  describe "POST /tickets/:id/comments" do
    it "creates a comment" do
      sign_in member

      expect do
        post ticket_comments_path(ticket), params: { comment: { body: "Looks good" } }
      end.to change(Comment, :count).by(1)

      expect(response).to redirect_to(ticket_path(ticket))
      expect(Comment.last.user).to eq(member)
    end

    it "redirects unauthenticated user" do
      post ticket_comments_path(ticket), params: { comment: { body: "Looks good" } }

      expect(response).to redirect_to(new_user_session_path)
    end

    it "blocks unauthorized users" do
      sign_in outsider

      post ticket_comments_path(ticket), params: { comment: { body: "Looks good" } }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /tickets/:id/comments/:id" do
    let!(:comment) { create(:comment, ticket: ticket, user: author, body: "Needs work") }

    it "deletes comment for author" do
      sign_in author

      expect do
        delete ticket_comment_path(ticket, comment)
      end.to change(Comment, :count).by(-1)

      expect(response).to redirect_to(ticket_path(ticket))
    end

    it "blocks non-author non-admin" do
      sign_in member

      expect do
        delete ticket_comment_path(ticket, comment)
      end.not_to change(Comment, :count)

      expect(response).to redirect_to(root_path)
    end
  end
end
