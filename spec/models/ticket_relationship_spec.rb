require 'rails_helper'

RSpec.describe TicketRelationship, type: :model do
  subject(:ticket_relationship) { create(:ticket_relationship) }

  describe 'associations' do
    it { is_expected.to belong_to(:source_ticket).class_name('Ticket') }
    it { is_expected.to belong_to(:target_ticket).class_name('Ticket') }
  end

  describe 'enums' do
    it do
      is_expected.to define_enum_for(:relationship_type)
        .with_values(blocks: 0, is_blocked_by: 1, relates_to: 2, duplicates: 3)
        .backed_by_column_of_type(:integer)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:relationship_type) }

    it 'validates uniqueness of source, target, and relationship type combination' do
      source = create(:ticket)
      target = create(:ticket)
      create(:ticket_relationship, source_ticket: source, target_ticket: target, relationship_type: :blocks)

      duplicate = build(:ticket_relationship, source_ticket: source, target_ticket: target, relationship_type: :blocks)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:relationship_type]).to include('has already been taken')
    end

    it 'does not allow self-referencing relationship' do
      ticket = create(:ticket)
      relationship = build(:ticket_relationship, source_ticket: ticket, target_ticket: ticket)

      expect(relationship).not_to be_valid
      expect(relationship.errors[:target_ticket]).to include('cannot reference the same ticket as source')
    end
  end
end
