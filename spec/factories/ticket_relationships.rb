FactoryBot.define do
  factory :ticket_relationship do
    association :source_ticket, factory: :ticket
    association :target_ticket, factory: :ticket
    relationship_type { :blocks }

    trait :relates_to do
      relationship_type { :relates_to }
    end
  end
end
