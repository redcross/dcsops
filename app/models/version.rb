class Version < PaperTrail::Version
  belongs_to :root, polymorphic: true
  belongs_to :chapter, class_name: 'Roster::Chapter'

  scope :for_type, -> type {
    where{(item_type == type) | (root_type == type)}
  }

  scope :for_root, -> obj {
    where{(item == obj) | (root == obj)}
  }

  scope :for_chapter, -> chapter {
    where{chapter_id == chapter}
  }
end