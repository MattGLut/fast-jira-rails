require 'rails_helper'

RSpec.describe LabelPolicy do
  let(:admin) { create(:user, :admin) }
  let(:project_manager) { create(:user, :project_manager) }
  let(:developer) { create(:user) }
  let(:outsider) { create(:user) }
  let(:project) { create(:project) }
  let(:label_record) { create(:label, project: project) }

  before do
    create(:project_membership, :manager, project: project, user: project_manager)
    create(:project_membership, project: project, user: developer)
  end

  permissions :index?, :show? do
    it 'allows project members and admin' do
      expect(described_class).to permit(admin, label_record)
      expect(described_class).to permit(project_manager, label_record)
      expect(described_class).to permit(developer, label_record)
    end

    it 'denies non-members' do
      expect(described_class).not_to permit(outsider, label_record)
    end
  end

  permissions :create?, :update?, :destroy? do
    it 'allows admin and project manager' do
      expect(described_class).to permit(admin, label_record)
      expect(described_class).to permit(project_manager, label_record)
    end

    it 'denies developers and outsiders' do
      expect(described_class).not_to permit(developer, label_record)
      expect(described_class).not_to permit(outsider, label_record)
    end
  end

  describe 'scope' do
    let!(:visible_label) { label_record }
    let!(:hidden_label) { create(:label) }

    it 'returns all labels for admin' do
      expect(described_class::Scope.new(admin, Label).resolve).to contain_exactly(visible_label, hidden_label)
    end

    it 'returns labels for member projects only' do
      expect(described_class::Scope.new(project_manager, Label).resolve).to contain_exactly(visible_label)
      expect(described_class::Scope.new(developer, Label).resolve).to contain_exactly(visible_label)
      expect(described_class::Scope.new(outsider, Label).resolve).to be_empty
    end
  end
end
