ActiveAdmin.register Roster::ShiftTerritory, as: 'Shift Territory' do

  menu parent: 'Roster'

  filter :region
  filter :name
  filter :enabled

  actions :all, except: [:destroy]

  show do
    default_main_content
    attributes_table do
      row("Number of Members") { resource.people.count }
    end
    vc_positions = resource.vc_positions.uniq
    panel "Matched VC Positions" do
      table_for vc_positions do
        column("Name") { |r| r[:name] }
      end
    end
  end

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :abbrev, :enabled, :shift_territory_code, :fips_code, :gis_name, :region_id)]
    end
  end

end
