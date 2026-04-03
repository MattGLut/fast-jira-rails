FactoryBot.define do
  factory :api_token do
    name { 'Claude Agent' }
    active { true }
    last_used_at { nil }
    user
  end
end
