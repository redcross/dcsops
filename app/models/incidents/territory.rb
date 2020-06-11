class Incidents::Territory < ApplicationRecord
  belongs_to :chapter, class_name: 'Roster::Chapter'
  belongs_to :dispatch_config, class_name: 'Scheduler::DispatchConfig'
  has_and_belongs_to_many :calendar_counties, class_name: 'Roster::County'

  validates :chapter, presence: true

  def self.for_chapter chapter
    where{chapter_id == chapter}
  end

  def self.default_for_chapter chapter
    find_by is_default: true, chapter_id: chapter
  end

  [:counties, :cities, :zip_codes].each do |meth|
    define_method :"#{meth}=" do |val|
      write_attribute meth, Array(val).select(&:present?)
    end
  end
end
