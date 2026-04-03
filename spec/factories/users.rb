FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'Password123!' }
    password_confirmation { password }
    first_name { 'Jane' }
    last_name { 'Doe' }
    role { :developer }

    trait :project_manager do
      role { :project_manager }
    end

    trait :admin do
      role { :admin }
    end
  end
end
