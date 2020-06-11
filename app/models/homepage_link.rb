class HomepageLink < ApplicationRecord
  belongs_to :region, class_name: 'Roster::Region'
  has_many :roles, class_name: 'HomepageLink::Role'
  has_attached_file :file
  do_not_validate_attachment_file_type :file
  accepts_nested_attributes_for :roles, allow_destroy: true

  def link
    file.file? && file.expiring_url || url
  end

  scope :for_region, -> (region) { where{(region_id == nil) | (region_id == region)}}

  class Role < ApplicationRecord
    self.table_name = :homepage_link_roles
    belongs_to :homepage_link, class_name: 'HomepageLink'
  end
end
