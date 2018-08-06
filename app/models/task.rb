class Task < ApplicationRecord
  validates :title, {presence: true}

  scope :done, ->{ where(done: true) }
  scope :undone, ->{ where(done: false) }
end
