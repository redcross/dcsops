class HomepageLink < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'
  has_many :roles, class_name: 'HomepageLink::Role'
  has_attached_file :file
  do_not_validate_attachment_file_type :file
  accepts_nested_attributes_for :roles, allow_destroy: true

  def link
    file.file? && file.expiring_url || url
  end

  scope :for_chapter, -> (chapter) { where{(chapter_id == nil) | (chapter_id == chapter)}}

  class Role < ActiveRecord::Base
    self.table_name = :homepage_link_roles
    belongs_to :homepage_link, class_name: 'HomepageLink'
  end
end
