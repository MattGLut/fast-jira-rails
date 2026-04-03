require "warden/test/helpers"

RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :system

  config.after(:each, type: :system) do
    Warden.test_reset!
  end
end
