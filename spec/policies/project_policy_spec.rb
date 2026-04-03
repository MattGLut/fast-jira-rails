require 'rails_helper'

RSpec.describe ProjectPolicy do
  let(:admin) { create(:user, :admin) }
  let(:project_manager) { create(:user, :project_manager) }
  let(:developer) { create(:user) }
  let(:outsider) { create(:user) }
  let(:project) { create(:project) }

  before do
    create(:project_membership, :manager, project: project, user: project_manager)
    create(:project_membership, project: project, user: developer)
  end

  permissions :index? do
    it 'allows all authenticated users' do
      expect(described_class).to permit(admin, project)
      expect(described_class).to permit(project_manager, project)
      expect(described_class).to permit(developer, project)
    end

    it 'denies guests' do
      expect(described_class).not_to permit(nil, project)
    end
  end

  permissions :show? do
    it 'allows admin and project members' do
      expect(described_class).to permit(admin, project)
      expect(described_class).to permit(project_manager, project)
      expect(described_class).to permit(developer, project)
    end

    it 'denies non-members' do
      expect(described_class).not_to permit(outsider, project)
    end
  end

  permissions :create? do
    it 'allows admin and project managers' do
      expect(described_class).to permit(admin, project)
      expect(described_class).to permit(project_manager, project)
    end

    it 'denies developers' do
      expect(described_class).not_to permit(developer, project)
    end
  end

  permissions :update? do
    it 'allows admin and project membership managers' do
      expect(described_class).to permit(admin, project)
      expect(described_class).to permit(project_manager, project)
    end

    it 'denies non-managers and outsiders' do
      expect(described_class).not_to permit(developer, project)
      expect(described_class).not_to permit(outsider, project)
    end
  end

  permissions :destroy? do
    it 'allows only admin' do
      expect(described_class).to permit(admin, project)
      expect(described_class).not_to permit(project_manager, project)
      expect(described_class).not_to permit(developer, project)
    end
  end

  describe 'scope' do
    let!(:member_project) { project }
    let!(:other_project) { create(:project) }

    it 'returns all projects for admin' do
      expect(described_class::Scope.new(admin, Project).resolve).to contain_exactly(member_project, other_project)
    end

    it 'returns only member projects for non-admin users' do
      expect(described_class::Scope.new(project_manager, Project).resolve).to contain_exactly(member_project)
      expect(described_class::Scope.new(developer, Project).resolve).to contain_exactly(member_project)
      expect(described_class::Scope.new(outsider, Project).resolve).to be_empty
    end
  end
end
