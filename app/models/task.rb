class Task < ApplicationRecord
  belongs_to :project, optional: true

  validates :title, {presence: true}

  scope :done, ->{ where(done: true) }
  scope :undone, ->{ where(done: false) }
end
