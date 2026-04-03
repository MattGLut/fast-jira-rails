require 'rails_helper'

RSpec.describe ActivityLog, type: :model do
  subject(:activity_log) { build(:activity_log) }

  describe 'associations' do
    it { is_expected.to belong_to(:ticket) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:action) }
  end
end
