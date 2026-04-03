require 'rails_helper'

RSpec.describe ApiTokenPolicy do
  let(:admin) { create(:user, :admin) }
  let(:project_manager) { create(:user, :project_manager) }
  let(:developer) { create(:user) }
  let(:api_token_record) { create(:api_token) }

  permissions :index?, :show?, :create?, :update?, :destroy? do
    it 'allows admin' do
      expect(described_class).to permit(admin, api_token_record)
    end

    it 'denies non-admin roles' do
      expect(described_class).not_to permit(project_manager, api_token_record)
      expect(described_class).not_to permit(developer, api_token_record)
    end
  end

  describe 'scope' do
    let!(:token_one) { create(:api_token) }
    let!(:token_two) { create(:api_token) }

    it 'returns all tokens for admin' do
      expect(described_class::Scope.new(admin, ApiToken).resolve).to contain_exactly(token_one, token_two)
    end

    it 'returns no tokens for non-admin users' do
      expect(described_class::Scope.new(project_manager, ApiToken).resolve).to be_empty
      expect(described_class::Scope.new(developer, ApiToken).resolve).to be_empty
    end
  end
end
