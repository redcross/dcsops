ActiveAdmin.register Roster::County, as: 'County' do

  menu parent: 'Roster'

  filter :chapter
  filter :name

  actions :all, except: [:destroy]

  show do
    default_main_content
    attributes_table do
      row("Number of Members") { resource.people.count }
    end
    data = resource.chapter.vc_import_data
    if data
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
      [params.fetch(resource_request_name, {}).permit(:name, :abbrev, :county_code, :fips_code, :gis_name, :vc_regex_raw, :chapter_id)]
    end
  end

end
