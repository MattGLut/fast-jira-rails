FactoryBot.define do
  factory :comment do
    body { 'A helpful comment' }
    agent_authored { false }
    ticket
    user

    trait :agent_authored do
      agent_authored { true }
    end
  end
end
