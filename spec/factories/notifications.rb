FactoryBot.define do
  factory :notification do
    message { 'Ticket assigned to you' }
    read { false }
    notification_type { 'assigned' }
    association :recipient, factory: :user
    ticket
    association :actor, factory: :user

    trait :read do
      read { true }
    end
  end
end
