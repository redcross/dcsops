class Incidents::Territory < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'
  belongs_to :dispatch_config, class_name: 'Scheduler::DispatchConfig'

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
