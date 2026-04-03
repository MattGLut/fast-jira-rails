require 'rails_helper'

RSpec.describe ProjectMembership, type: :model do
  subject(:project_membership) { create(:project_membership) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'enums' do
    it do
      is_expected.to define_enum_for(:role)
        .with_values(member: 0, manager: 1)
        .with_default(:member)
        .backed_by_column_of_type(:integer)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:project_id) }
  end
end
