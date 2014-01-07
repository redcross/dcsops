class Incidents::Attachment < ActiveRecord::Base
  has_paper_trail meta: {root_type: 'Incidents::Incident', root_id: ->(obj){obj.incident_id}, chapter_id: ->(obj){obj.incident.chapter_id} }
  has_attached_file :file, styles: {thumbnail: '60x60#', thumbnail2x: '120x120#', large: '600x600#'}
  before_post_process :skip_convert_unless_image

  belongs_to :incident, class_name: 'Incidents::Incident', inverse_of: :attachments

  validates :incident, :name, presence: true
  validates_attachment :file, presence: true, 
                              size: { in: 0..2.megabytes }


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