class HomepageLink < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'
  has_and_belongs_to_many :roles, class_name: 'Roster::Role'
  has_attached_file :file
  do_not_validate_attachment_file_type :file

  def link
    file.file? && file.expiring_url || url
  end

  scope :for_chapter, -> (chapter) { where{(chapter_id == nil) | (chapter_id == chapter)}}
end
