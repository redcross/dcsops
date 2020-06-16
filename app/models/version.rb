class Version < PaperTrail::Version
  belongs_to :root, polymorphic: true
  belongs_to :chapter, class_name: 'Roster::Chapter'

  scope :for_type, -> type {
    where(item_type: type).or(where(root_type: type))
  }

  scope :for_root, -> obj {
    where(item: obj).or(where(root: obj))
  }

  scope :for_chapter, -> chapter {
    where(chapter: chapter)
  }
end