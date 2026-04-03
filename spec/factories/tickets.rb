FactoryBot.define do
  factory :ticket do
    sequence(:title) { |n| "Ticket #{n}" }
    description { 'Ticket details' }
    status { :todo }
    priority { :medium }
    ticket_type { :task }
    story_points { 3 }
    due_date { 1.week.from_now.to_date }
    project
    association :reporter, factory: :user
    assignee { nil }

    trait :assigned do
      association :assignee, factory: :user
    end

    trait :bug do
      ticket_type { :bug }
      priority { :high }
      story_points { nil }
    end
  end
end
