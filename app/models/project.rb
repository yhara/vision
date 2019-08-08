class Project < ApplicationRecord
  acts_as_list
  has_many :tasks

  scope :active, ->{ where(archived_at: nil).order(:position) }
  scope :archived, ->{ where.not(archived_at: nil).order(:position) }

  def archive
    update(archived_at: Time.now, position: nil)
  end
end
