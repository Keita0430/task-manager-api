FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Task #{n}" }
    sequence(:description) { |n| "Description #{n}" }
  end
end
