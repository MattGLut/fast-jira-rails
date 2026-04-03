require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { create(:user) }

  describe 'devise modules' do
    it 'uses the expected devise modules' do
      expect(described_class.devise_modules).to include(
        :database_authenticatable,
        :registerable,
        :recoverable,
        :rememberable,
        :validatable
      )
    end
  end

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

  describe 'validations' do
    subject(:user) { create(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'name attributes' do
    it 'stores first_name and last_name values' do
      named_user = build(:user, first_name: 'John', last_name: 'Doe')

      expect(named_user.first_name).to eq('John')
      expect(named_user.last_name).to eq('Doe')
    end
  end
end
