class Roster::PositionMembership < ActiveRecord::Base
  belongs_to :person
  belongs_to :position

  #validates_presence_of :person, :position

  def self.destroy_all_for_chapter(chapter)
    self.joins{person}.where{(person.chapter_id == chapter.id) & ((persistent == nil) | (persistent == false))}.delete_all
  end
end