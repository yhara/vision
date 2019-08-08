class Project < ApplicationRecord
  acts_as_list
  has_many :tasks

  scope :active, ->{ where(archived_at: nil).order(:position) }
  scope :archived, ->{ where.not(archived_at: nil).order(:position) }

  def archived
    !!archived_at
  end

  def archived=(b)
    if b == "1"
      self.archived_at = Time.now
    else
      self.archived_at = nil
    end
  end
end
