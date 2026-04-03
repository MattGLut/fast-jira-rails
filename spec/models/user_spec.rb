require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { create(:user) }

  describe 'enums' do
    it do
      is_expected.to define_enum_for(:role)
        .with_values(developer: 0, project_manager: 1, admin: 2)
        .with_default(:developer)
        .backed_by_column_of_type(:integer)
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:project_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:projects).through(:project_memberships) }
    it { is_expected.to have_many(:tickets).with_foreign_key(:reporter_id).dependent(:nullify) }

    it do
      is_expected.to have_many(:assigned_tickets)
        .class_name('Ticket')
        .with_foreign_key(:assignee_id)
        .dependent(:nullify)
    end

    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).class_name('Notification').dependent(:destroy) }
    it { is_expected.to have_many(:api_tokens).dependent(:destroy) }
  end
end
