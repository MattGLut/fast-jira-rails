require 'rails_helper'

RSpec.describe CommentPolicy do
  let(:admin) { create(:user, :admin) }
  let(:project_manager) { create(:user, :project_manager) }
  let(:author) { create(:user) }
  let(:member) { create(:user) }
  let(:outsider) { create(:user) }
  let(:project) { create(:project) }
  let(:ticket) { create(:ticket, project: project) }
  let(:comment) { create(:comment, ticket: ticket, user: author) }

  before do
    create(:project_membership, :manager, project: project, user: project_manager)
    create(:project_membership, project: project, user: author)
    create(:project_membership, project: project, user: member)
  end

  permissions :index?, :show?, :create? do
    it 'allows project members' do
      expect(described_class).to permit(admin, comment)
      expect(described_class).to permit(project_manager, comment)
      expect(described_class).to permit(author, comment)
      expect(described_class).to permit(member, comment)
    end

    it 'denies non-members' do
      expect(described_class).not_to permit(outsider, comment)
    end
  end

  permissions :update?, :destroy? do
    it 'allows admin and comment author' do
      expect(described_class).to permit(admin, comment)
      expect(described_class).to permit(author, comment)
    end

    it 'denies non-authors' do
      expect(described_class).not_to permit(project_manager, comment)
      expect(described_class).not_to permit(member, comment)
      expect(described_class).not_to permit(outsider, comment)
    end
  end

  describe 'scope' do
    let!(:visible_comment) { comment }
    let!(:hidden_comment) { create(:comment) }

    it 'returns all comments for admin' do
      expect(described_class::Scope.new(admin, Comment).resolve).to contain_exactly(visible_comment, hidden_comment)
    end

    it 'returns only comments in member projects for non-admin users' do
      expect(described_class::Scope.new(project_manager, Comment).resolve).to contain_exactly(visible_comment)
      expect(described_class::Scope.new(member, Comment).resolve).to contain_exactly(visible_comment)
      expect(described_class::Scope.new(outsider, Comment).resolve).to be_empty
    end
  end
end
