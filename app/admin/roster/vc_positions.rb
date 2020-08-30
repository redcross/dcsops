ActiveAdmin.register Roster::VcPosition, as: 'VC Position' do
  menu parent: 'Roster'

  filter :region
  filter :name
  filter :positions
  filter :shift_territories

  show do
    default_main_content

    panel "DCSOps Position Configurations" do
      table_for resource.vc_position_configurations do
        column("Position") { |r| r.position.name }
        column("Shift Territory") { |r| r.shift_territory.name if r.shift_territory.present? }
      end
    end
  end

  form do |f|
    f.inputs
    if f.object.new_record?
      panel "DCSOps Position Configurations" do
        para "In order to add new Position Configurations, you have to save your new VC Position.  This is so we can populate the dropdowns with Positions and Shift Territories only from the region you're working in.  Please hit 'Edit Vc Position' as soon as you save this new VC Position to configure the DCSOps Positions and Shift Territories."
      end
    else
      f.inputs "DCSOps Position Configurations" do
        f.has_many :vc_position_configurations, heading: "DCSOps Position Configurations", allow_destroy: true do |f|
          f.input :position, collection: Roster::Position.where(region: resource.region).sort_by(&:name)
          f.input :shift_territory, collection: Roster::ShiftTerritory.where(region: resource.region).sort_by(&:name)
        end
      end
    end
    f.actions
  end

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :region_id, vc_position_configurations_attributes: [:id, :_destroy, :position_id, :shift_territory_id])]
    end
  end
end
