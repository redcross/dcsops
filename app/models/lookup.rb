class Lookup < ApplicationRecord
  belongs_to :region, class_name: 'Roster::Region'

  validates :region, :scope, :name, :value, presence: true

  alias_attribute :humanized, :name

  assignable_values_for :scope do
    %w(Incidents::EventLog#source Incidents::Incident#vacate_type).map{|x| {x => x}}.reduce(&:merge)
  end

  def self.for_region_and_scope(region, scope_name)
    where{(region_id == nil) | (region_id == region)}.where{scope == scope_name}.order(:ordinal)
  end
end
