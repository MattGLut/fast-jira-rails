require 'rails_helper'

RSpec.describe Ticket, type: :model do
  subject(:ticket) { build(:ticket) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:reporter).class_name('User') }
    it { is_expected.to belong_to(:assignee).class_name('User').optional }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:activity_logs).dependent(:destroy) }
    it { is_expected.to have_many(:pr_links).dependent(:destroy) }
    it { is_expected.to have_many(:ticket_labels).dependent(:destroy) }
    it { is_expected.to have_many(:labels).through(:ticket_labels) }

    it do
      is_expected.to have_many(:source_relationships)
        .class_name('TicketRelationship')
        .with_foreign_key(:source_ticket_id)
        .dependent(:destroy)
    end

    it do
      is_expected.to have_many(:target_relationships)
        .class_name('TicketRelationship')
        .with_foreign_key(:target_ticket_id)
        .dependent(:destroy)
    end
  end

  describe 'enums' do
    it do
      is_expected.to define_enum_for(:status)
        .with_values(todo: 0, in_progress: 1, code_review: 2, qa: 3, done: 4)
        .with_default(:todo)
        .backed_by_column_of_type(:integer)
    end

    it do
      is_expected.to define_enum_for(:priority)
        .with_values(low: 0, medium: 1, high: 2, critical: 3)
        .with_default(:medium)
        .backed_by_column_of_type(:integer)
    end

    it do
      is_expected.to define_enum_for(:ticket_type)
        .with_values(task: 0, story: 1, bug: 2)
        .backed_by_column_of_type(:integer)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to allow_value(nil, 1, 2, 3, 5, 8, 13).for(:story_points) }
    it { is_expected.not_to allow_value(4, 7, 21).for(:story_points) }
  end

  describe 'callbacks' do
    it 'auto-assigns sequential ticket numbers per project' do
      project = create(:project, key: 'FAST')
      first_ticket = create(:ticket, project: project, reporter: create(:user))
      second_ticket = create(:ticket, project: project, reporter: create(:user))

      expect(first_ticket.ticket_number).to eq(1)
      expect(second_ticket.ticket_number).to eq(2)
      expect(project.reload.ticket_sequence).to eq(2)
    end
  end

  describe '#key' do
    it 'returns project key with ticket number' do
      ticket = create(:ticket, project: create(:project, key: 'PROJ'), reporter: create(:user))

      expect(ticket.key).to eq("PROJ-#{ticket.ticket_number}")
    end
  end
end
