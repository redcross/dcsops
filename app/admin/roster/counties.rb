ActiveAdmin.register Roster::County, namespace: 'roster_admin', as: 'County' do

  menu parent: 'Roster'

  filter :chapter
  filter :name

  actions :all, except: [:destroy]

  controller do
    def resource_params
      request.get? ? [] : [params.require(:county).permit(:name, :abbrev, :county_code, :fips_code, :gis_name, :vc_regex_raw)]
    end
  end

end
