class Incidents::ResponseTerritory < ActiveRecord::Base
  belongs_to :region, class_name: 'Roster::Region'
  belongs_to :dispatch_config, class_name: 'Scheduler::DispatchConfig'
  has_and_belongs_to_many :shift_territories, class_name: 'Roster::ShiftTerritory'

  validates :region, presence: true

  def self.for_region region
    where(region: region)
  end

  def self.default_for_region region
    find_by is_default: true, region_id: region
  end

  [:counties, :cities, :zip_codes].each do |meth|
    define_method :"#{meth}=" do |val|
      write_attribute meth, Array(val).select(&:present?)
    end
  end
end
