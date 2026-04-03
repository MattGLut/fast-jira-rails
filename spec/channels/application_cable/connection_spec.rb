require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { create(:user) }

  it "connects with a valid user" do
    connect "/cable", env: { "warden" => double(user: user) }

    expect(connection.current_user).to eq(user)
  end

  it "rejects connection without a user" do
    expect {
      connect "/cable", env: { "warden" => double(user: nil) }
    }.to have_rejected_connection
  end

  it "identifies current_user from warden" do
    connect "/cable", env: { "warden" => double(user: user) }

    expect(connection.current_user.id).to eq(user.id)
  end
end
