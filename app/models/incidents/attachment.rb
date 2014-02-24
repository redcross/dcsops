class Incidents::Attachment < Incidents::DataModel
  has_attached_file :file, styles: {thumbnail: '60x60#', thumbnail2x: '120x120#', large: '600x600#'}
  before_post_process :skip_convert_unless_image

  validates :incident, :name, presence: true
  validates_attachment :file, presence: true, 
                              size: { in: 0..2.megabytes }
  do_not_validate_attachment_file_type :file


  assignable_values_for :attachment_type do
    %w(file damage_assessment_photo exterior_photo team_photo pa_release)
  end

  def image?
    file.present? && file.content_type =~ /^image\//
  end

  def skip_convert_unless_image
    image?.present?
  end
end