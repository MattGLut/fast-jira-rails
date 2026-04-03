FactoryBot.define do
  factory :pr_link do
    sequence(:url) { |n| "https://github.com/example/repo/pull/#{n}" }
    sequence(:title) { |n| "PR #{n}" }
    status { :open }
    ticket
    user

    trait :merged do
      status { :merged }
    end

    trait :closed do
      status { :closed }
    end
  end
end
