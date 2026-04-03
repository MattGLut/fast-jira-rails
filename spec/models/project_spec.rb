require 'rails_helper'

RSpec.describe Project, type: :model do
  subject(:project) { build(:project) }

  describe 'associations' do
    it { is_expected.to have_many(:project_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:members).through(:project_memberships) }
    it { is_expected.to have_many(:tickets).dependent(:destroy) }
    it { is_expected.to have_many(:labels).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:key) }
    it { is_expected.to validate_uniqueness_of(:key) }

    it 'validates key format as uppercase letters (2-6 chars)' do
      expect(build(:project, key: 'ab')).not_to be_valid
      expect(build(:project, key: 'A')).not_to be_valid
      expect(build(:project, key: 'ABCDEFG')).not_to be_valid
      expect(build(:project, key: 'AB12')).not_to be_valid
      expect(build(:project, key: 'PROJ')).to be_valid
    end
  end
end
