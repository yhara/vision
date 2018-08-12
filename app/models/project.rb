class Project < ApplicationRecord
  acts_as_list
  has_many :tasks

  scope :active, ->{ where(archived: false).order(:position) }
  scope :archived, ->{ where(archived: true).order(:position) }

  before_validation do
    self.archived = false if self.archived.nil?
  end

  def archive
    update(archived: true, position: nil)
  end
end
