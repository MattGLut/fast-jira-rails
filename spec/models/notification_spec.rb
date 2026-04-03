require 'rails_helper'

RSpec.describe Notification, type: :model do
  subject(:notification) { build(:notification) }

  describe 'associations' do
    it { is_expected.to belong_to(:recipient).class_name('User') }
    it { is_expected.to belong_to(:ticket).optional }
    it { is_expected.to belong_to(:actor).class_name('User') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:message) }
  end

  describe 'scopes' do
    it 'returns unread notifications' do
      unread_notification = create(:notification, read: false)
      create(:notification, :read)

      expect(described_class.unread).to contain_exactly(unread_notification)
    end

    it 'returns recent notifications from last 30 days' do
      recent_notification = create(:notification)
      old_notification = create(:notification)
      old_notification.update_column(:created_at, 45.days.ago)

      expect(described_class.recent).to include(recent_notification)
      expect(described_class.recent).not_to include(old_notification)
    end
  end
end
