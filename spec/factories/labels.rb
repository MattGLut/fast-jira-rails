FactoryBot.define do
  factory :label do
    sequence(:name) { |n| "label-#{n}" }
    color { '#FF5733' }
    project
  end
end
