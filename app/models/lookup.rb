class Lookup < ApplicationRecord
  belongs_to :chapter, class_name: 'Roster::Chapter'

  validates :chapter, :scope, :name, :value, presence: true

  alias_attribute :humanized, :name

  assignable_values_for :scope do
    %w(Incidents::EventLog#source Incidents::Incident#vacate_type).map{|x| {x => x}}.reduce(&:merge)
  end

  def self.for_chapter_and_scope(chapter, scope_name)
    where{(chapter_id == nil) | (chapter_id == chapter)}.where{scope == scope_name}.order(:ordinal)
  end
end
