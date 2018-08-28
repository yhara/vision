class Task < ApplicationRecord
  belongs_to :project, optional: true

  validates :title, presence: true
  validates :project, presence: true, if: ->{ project_id != nil }

  scope :done, ->{ where(done: true) }
  scope :undone, ->{ where(done: false) }
end
