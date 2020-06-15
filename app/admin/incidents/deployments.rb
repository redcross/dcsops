ActiveAdmin.register Incidents::Deployment, as: 'Deployment' do
  menu parent: 'Incidents'

  actions :index, :show

  filter :disaster
  filter :date_first_seen
  filter :date_last_seen

  index do
    column :id
    column("CID") { |d| d.person.try :region_id }
    column(:disaster)
    column :person
    column :gap
    column :date_first_seen
    column :date_last_seen
    actions
  end

  controller do
    def collection
      @collection ||= super.includes(:person, :disaster)
    end
  end

end
