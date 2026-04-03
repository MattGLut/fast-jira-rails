require 'rails_helper'

RSpec.describe Comment, type: :model do
  subject(:comment) { build(:comment) }

  describe 'associations' do
    it { is_expected.to belong_to(:ticket) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:body) }
  end

  describe 'defaults' do
    it 'defaults agent_authored to false' do
      expect(build(:comment).agent_authored).to be(false)
    end
  end

  describe 'broadcast callbacks' do
    let(:ticket) { create(:ticket, project: create(:project), reporter: create(:user)) }

    it 'broadcasts after creation' do
      comment = build(:comment, ticket: ticket, user: create(:user))

      expect(comment).to receive(:broadcast_append_to).with(
        "ticket_#{ticket.id}_comments",
        hash_including(
          target: 'comments_list',
          partial: 'comments/comment',
          locals: { comment: comment, ticket: ticket }
        )
      )

      comment.save!
    end
  end
end
