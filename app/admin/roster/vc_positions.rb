ActiveAdmin.register Roster::VcPosition, as: 'VC Position' do
  menu parent: 'Roster'

  filter :region
  filter :name
  filter :positions
  filter :shift_territories

  show do
    default_main_content

    panel "Configuration" do
      table_for resource.vc_position_configurations do
        column("Position") { |r| r.position.name }
        column("Shift Territory") { |r| r.shift_territory.name }
      end
    end
  end

  form do |f|
    f.inputs
    f.inputs do
      f.has_many :vc_position_configurations, allow_destroy: true do |f|
        f.input :position, collection: Roster::Position.where(region: resource.region).sort_by(&:name)
        f.input :shift_territory, collection: Roster::ShiftTerritory.where(region: resource.region).sort_by(&:name)
      end
    end
    f.actions
  end

end
