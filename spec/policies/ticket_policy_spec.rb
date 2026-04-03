require 'rails_helper'

RSpec.describe TicketPolicy do
  let(:admin) { create(:user, :admin) }
  let(:project_manager) { create(:user, :project_manager) }
  let(:developer) { create(:user) }
  let(:assignee) { create(:user) }
  let(:outsider) { create(:user) }
  let(:project) { create(:project) }
  let(:other_project) { create(:project) }
  let(:ticket) { create(:ticket, project: project, reporter: developer, assignee: assignee) }

  before do
    create(:project_membership, :manager, project: project, user: project_manager)
    create(:project_membership, project: project, user: developer)
    create(:project_membership, project: project, user: assignee)
  end

  permissions :index?, :show?, :create? do
    it 'allows admins and project members' do
      expect(described_class).to permit(admin, ticket)
      expect(described_class).to permit(project_manager, ticket)
      expect(described_class).to permit(developer, ticket)
    end

    it 'denies non-members' do
      expect(described_class).not_to permit(outsider, ticket)
    end
  end

  permissions :update? do
    it 'allows admin, project manager, reporter, and assignee' do
      expect(described_class).to permit(admin, ticket)
      expect(described_class).to permit(project_manager, ticket)
      expect(described_class).to permit(developer, ticket)
      expect(described_class).to permit(assignee, ticket)
    end

    it 'denies users without ownership/assignment rights' do
      other_member = create(:user)
      create(:project_membership, project: project, user: other_member)

      expect(described_class).not_to permit(other_member, ticket)
      expect(described_class).not_to permit(outsider, ticket)
    end
  end

  permissions :destroy? do
    it 'allows admin and project manager' do
      expect(described_class).to permit(admin, ticket)
      expect(described_class).to permit(project_manager, ticket)
    end

    it 'denies developers and outsiders' do
      expect(described_class).not_to permit(developer, ticket)
      expect(described_class).not_to permit(outsider, ticket)
    end
  end

  permissions :assign? do
    it 'allows admin, project manager, and project members' do
      expect(described_class).to permit(admin, ticket)
      expect(described_class).to permit(project_manager, ticket)
      expect(described_class).to permit(developer, ticket)
    end

    it 'denies outsiders' do
      expect(described_class).not_to permit(outsider, ticket)
    end
  end

  permissions :transition? do
    it 'allows admin, project manager, and assignee' do
      expect(described_class).to permit(admin, ticket)
      expect(described_class).to permit(project_manager, ticket)
      expect(described_class).to permit(assignee, ticket)
    end

    it 'denies non-assignee developers and outsiders' do
      expect(described_class).not_to permit(developer, ticket)
      expect(described_class).not_to permit(outsider, ticket)
    end
  end

  describe 'scope' do
    let!(:ticket_in_member_project) { ticket }
    let!(:ticket_in_other_project) { create(:ticket, project: other_project) }

    it 'returns all tickets for admin' do
      expect(described_class::Scope.new(admin, Ticket).resolve).to contain_exactly(ticket_in_member_project, ticket_in_other_project)
    end

    it 'returns only tickets from projects the user belongs to' do
      expect(described_class::Scope.new(project_manager, Ticket).resolve).to contain_exactly(ticket_in_member_project)
      expect(described_class::Scope.new(developer, Ticket).resolve).to contain_exactly(ticket_in_member_project)
      expect(described_class::Scope.new(outsider, Ticket).resolve).to be_empty
    end
  end
end
