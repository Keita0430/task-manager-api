class Task < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }

  enum :status, { todo: 0, in_progress: 1, done: 2, pending: 3 }, validate: true
end
