class Lookup < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'

  validates :scope, :name, :value, presence: true

  alias_attribute :humanized, :name

  assignable_values_for :scope do
    %w(Incidents::EventLog#source).map{|x| {x => x}}.reduce(&:merge)
  end

  def self.for_chapter_and_scope(chapter, scope_name)
    where{(chapter_id == nil) | (chapter_id == chapter)}.where{scope == scope_name}.order{ordinal.asc}
  end
end
