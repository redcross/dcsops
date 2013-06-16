class MOTD < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'

  scope :active, ->(chapter){now = chapter.time_zone.now; where{(chapter_id == chapter) & ((begins == nil) | (begins <= now)) & ((ends == nil) | (ends >= now))}}
end
