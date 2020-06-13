class Version < PaperTrail::Version
  belongs_to :root, polymorphic: true
  belongs_to :region, class_name: 'Roster::Region'

  scope :for_type, -> type {
    where{(item_type == type) | (root_type == type)}
  }

  scope :for_root, -> obj {
    where{(item == obj) | (root == obj)}
  }

  scope :for_region, -> region {
    where(region: region)
  }
end