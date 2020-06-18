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
    data = resource.region.vc_import_data
    if data && resource.vc_regex_raw
      positions = data.positions_matching resource.vc_regex_raw
      panel "Matched VC Positions" do
        table_for positions do
          column("Name") { |r| r[:name] }
          column("Number of Matches") { |r| r[:count] }
        end
      end
    end
  end

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :abbrev, :enabled, :shift_territory_code, :fips_code, :gis_name, :vc_regex_raw, :region_id)]
    end
  end

end
