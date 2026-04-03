FactoryBot.define do
  factory :project_membership do
    project
    user
    role { :member }

    trait :manager do
      role { :manager }
    end
  end
end
