require 'rails_helper'

RSpec.describe NotificationPolicy do
  let(:admin) { create(:user, :admin) }
  let(:recipient) { create(:user) }
  let(:project_manager) { create(:user, :project_manager) }
  let(:other_developer) { create(:user) }
  let(:notification) { create(:notification, recipient: recipient, actor: project_manager) }

  permissions :index?, :show?, :update?, :destroy? do
    it 'allows only the recipient' do
      expect(described_class).to permit(recipient, notification)
      expect(described_class).not_to permit(admin, notification)
      expect(described_class).not_to permit(project_manager, notification)
      expect(described_class).not_to permit(other_developer, notification)
    end
  end

  permissions :create? do
    it 'denies everyone' do
      expect(described_class).not_to permit(admin, notification)
      expect(described_class).not_to permit(project_manager, notification)
      expect(described_class).not_to permit(recipient, notification)
    end
  end

  describe 'scope' do
    let!(:own_notification) { notification }
    let!(:other_notification) { create(:notification) }

    it 'returns only recipient notifications' do
      expect(described_class::Scope.new(recipient, Notification).resolve).to contain_exactly(own_notification)
      expect(described_class::Scope.new(admin, Notification).resolve).to be_empty
      expect(described_class::Scope.new(project_manager, Notification).resolve).to be_empty
    end
  end
end
