require 'rails_helper'

RSpec.describe PrLink, type: :model do
  subject(:pr_link) { build(:pr_link) }

  describe 'associations' do
    it { is_expected.to belong_to(:ticket) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'enums' do
    it do
      is_expected.to define_enum_for(:status)
        .with_values(open: 0, merged: 1, closed: 2)
        .with_default(:open)
        .backed_by_column_of_type(:integer)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to allow_value('http://example.com/pr/1').for(:url) }
    it { is_expected.to allow_value('https://example.com/pr/1').for(:url) }
    it { is_expected.not_to allow_value('ftp://example.com/pr/1').for(:url) }
  end
end
