class Roster::Membership < ApplicationRecord
  self.abstract_class = true

  belongs_to :person

  def self.for_chapter chapter 
    joins(:person).where{(person.chapter_id == chapter)}
  end

  def self.not_persistent
    where{(persistent == nil) | (persistent == false)}
  end

  def self.destroy_all_for_chapter(chapter)
    self.for_chapter(chapter).not_persistent.delete_all
  end
end