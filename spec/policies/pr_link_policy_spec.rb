require 'rails_helper'

RSpec.describe PrLinkPolicy do
  let(:admin) { create(:user, :admin) }
  let(:project_manager) { create(:user, :project_manager) }
  let(:creator) { create(:user) }
  let(:member) { create(:user) }
  let(:outsider) { create(:user) }
  let(:project) { create(:project) }
  let(:ticket) { create(:ticket, project: project) }
  let(:pr_link) { create(:pr_link, ticket: ticket, user: creator) }

  before do
    create(:project_membership, :manager, project: project, user: project_manager)
    create(:project_membership, project: project, user: creator)
    create(:project_membership, project: project, user: member)
  end

  permissions :index?, :show?, :create? do
    it 'allows project members and admins' do
      expect(described_class).to permit(admin, pr_link)
      expect(described_class).to permit(project_manager, pr_link)
      expect(described_class).to permit(creator, pr_link)
      expect(described_class).to permit(member, pr_link)
    end

    it 'denies non-members' do
      expect(described_class).not_to permit(outsider, pr_link)
    end
  end

  permissions :destroy? do
    it 'allows admins and creator' do
      expect(described_class).to permit(admin, pr_link)
      expect(described_class).to permit(creator, pr_link)
    end

    it 'denies non-creators' do
      expect(described_class).not_to permit(project_manager, pr_link)
      expect(described_class).not_to permit(member, pr_link)
      expect(described_class).not_to permit(outsider, pr_link)
    end
  end

  permissions :update? do
    it 'allows admins and creator' do
      expect(described_class).to permit(admin, pr_link)
      expect(described_class).to permit(creator, pr_link)
    end

    it 'denies non-creators' do
      expect(described_class).not_to permit(project_manager, pr_link)
      expect(described_class).not_to permit(member, pr_link)
      expect(described_class).not_to permit(outsider, pr_link)
    end
  end

  describe 'scope' do
    let!(:visible_pr_link) { pr_link }
    let!(:hidden_pr_link) { create(:pr_link) }

    it 'returns all pr links for admin' do
      expect(described_class::Scope.new(admin, PrLink).resolve).to contain_exactly(visible_pr_link, hidden_pr_link)
    end

    it 'returns only project pr links for members' do
      expect(described_class::Scope.new(project_manager, PrLink).resolve).to contain_exactly(visible_pr_link)
      expect(described_class::Scope.new(member, PrLink).resolve).to contain_exactly(visible_pr_link)
      expect(described_class::Scope.new(outsider, PrLink).resolve).to be_empty
    end
  end
end
