require 'rails_helper'

RSpec.describe ApiToken, type: :model do
  subject(:api_token) { create(:api_token) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'token generation' do
    it 'generates a secure token with expected length' do
      expect(api_token.token).to be_present
      expect(api_token.token.length).to eq(36)
    end
  end

  describe 'scopes' do
    it 'returns only active tokens' do
      active_token = create(:api_token, active: true)
      create(:api_token, active: false)

      expect(described_class.active).to contain_exactly(active_token)
    end
  end
end
