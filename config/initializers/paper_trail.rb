PaperTrail::Version.module_eval do
  belongs_to :root, polymorphic: true
  belongs_to :chapter, class_name: 'Roster::Chapter'
end