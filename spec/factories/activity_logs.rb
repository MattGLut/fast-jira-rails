FactoryBot.define do
  factory :activity_log do
    action { 'status_changed' }
    field_changed { 'status' }
    old_value { 'todo' }
    new_value { 'in_progress' }
    ticket
    user
  end
end
