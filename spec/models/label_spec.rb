require 'rails_helper'

RSpec.describe Label, type: :model do
  subject(:label) { create(:label) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:ticket_labels).dependent(:destroy) }
    it { is_expected.to have_many(:tickets).through(:ticket_labels) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:color) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:project_id) }

    it { is_expected.to allow_value('#FF5733', '#fff').for(:color) }
    it { is_expected.not_to allow_value('red', '123456', '#12', '#GGGGGG').for(:color) }
  end
end
