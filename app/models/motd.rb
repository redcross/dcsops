class MOTD < ApplicationRecord
  belongs_to :chapter, class_name: 'Roster::Chapter'

  scope :with_chapter_or_none, -> (chapter) { where(chapter: chapter).or(where(chapter: nil)) }
  scope :beginning_before, -> (now) { where(begins: nil).or(where('begins <= ?', now)) }
  scope :ending_after,     -> (now) { where(ends: nil).or(where('ends >= ?', now)) }
  scope :active, -> (chapter) do
    now = chapter.time_zone.now
    with_chapter_or_none(chapter).beginning_before(now).ending_after(now)
  end

  def path_regex
    @compiled_regex ||= (path_regex_raw && Regexp.new(path_regex_raw))
  end
end
