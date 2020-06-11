class Incidents::Territory < ActiveRecord::Base
  belongs_to :region, class_name: 'Roster::Region'
  belongs_to :dispatch_config, class_name: 'Scheduler::DispatchConfig'
  has_and_belongs_to_many :calendar_counties, class_name: 'Roster::County'

  validates :region, presence: true

  def self.for_region region
    where{region_id == region}
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
