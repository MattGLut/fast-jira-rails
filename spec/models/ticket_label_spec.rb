require 'rails_helper'

RSpec.describe TicketLabel, type: :model do
  subject(:ticket_label) { create(:ticket_label) }

  describe 'associations' do
    it { is_expected.to belong_to(:ticket) }
    it { is_expected.to belong_to(:label) }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:label_id).scoped_to(:ticket_id) }
  end
end
