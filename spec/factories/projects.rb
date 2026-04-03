FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    sequence(:key) do |n|
      first = ((n / 26) % 26)
      second = (n % 26)
      "PR#{(65 + first).chr}#{(65 + second).chr}"
    end
    description { 'Project description' }
    ticket_sequence { 0 }
  end
end
