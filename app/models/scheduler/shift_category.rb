class Scheduler::ShiftCategory < ApplicationRecord
  belongs_to :chapter, class_name: 'Roster::Chapter'
  has_many :shifts, class_name: 'Scheduler::Shift'

  def self.for_chapter chapter
    where(chapter: chapter)
  end

  def display_name
    "#{chapter_id} - #{name}"
  end

  default_scope { order(:ordinal) }
end
