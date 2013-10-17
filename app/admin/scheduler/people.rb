ActiveAdmin.register Roster::Person, as: 'Person' do
  batch_action :destroy, false
  batch_action :edit, false

  actions :all, except: [:destroy]

  menu parent: 'Roster'

  index do
    column("CID") {|p| p.chapter_id }
    column :name_last_first, sortable: "last_name"
    column :username
    column :last_login

    actions do |person|
      link_to "Impersonate", impersonate_scheduler_admin_person_path(person) if authorized?(:impersonate, person)
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :first_name
      f.input :last_name
    end
    f.actions
    f.has_many :county_memberships do |county_form|
      county_form.input :county
      county_form.input :persistent
      county_form.input :_destroy, as: :boolean, label: "Remove"
    end
    f.actions
    f.has_many :position_memberships do |form|
      form.input :position
      form.input :persistent
      form.input :_destroy, as: :boolean, label: "Remove"
    end
    f.actions
  end

  show do
    #attributes_table do
    #  row :first_name
    #  row :vc_id
    #  row :vc_member_number
    #end
    
    columns do
      column do
        panel "Positions" do
          table_for person.position_memberships do
            column( :name) { |rec| rec.position && rec.position.name }
            column(:persistent) { |rec| rec.persistent ? 'Yes' : ''}
            column(:roles) {|rec| rec.roles.map(&:name).join ", "}
          end
        end
      end
      column do
        panel "Counties" do
          table_for person.county_memberships do
            column( :name) { |rec| rec.county && rec.county.name }
            column(:persistent) { |rec| rec.persistent ? 'Yes' : ''}
          end
        end
      end
    end
  end

  scope :default, default: true do |scope|
    scope.uniq
  end

  member_action :impersonate, method: [:get, :delete] do
    #p = resource
    #p.reset_persistence_token! if p.persistence_token.blank?
    #sess = Roster::Session.create!(p, true)
    if request.get?
      session[:impersonating_user_id] = resource.id
      redirect_to '/'
    else
      session[:impersonating_user_id] = nil
      redirect_to :back
    end
  end
  action_item only: :show, if: proc{ authorized? :impersonate, resource} do
    link_to "Possess", url_for(action: :impersonate, only_path: true)
  end
  action_item only: :show do
    link_to "Volunteer Connection", resource.vc_profile_url
  end


  filter :first_name
  filter :last_name
  filter :counties_id, :as => :check_boxes, :collection => proc {Roster::County.all}
  filter :positions_id, as: :check_boxes, collection: proc {Roster::Position.all}
  filter :last_login, as: :date_range

  def date_ranges
    [ ["Now", -2],
      ["1 Week", 7],
      ["2 Weeks", 14],
      ["1 Month", 30],
      ["2 Months", 60],
      ["3 Months", 90],
      ["6 Months", 180]
    ]
  end

  controller do

    before_filter only: :index do
      params['q'] ||= {counties_id_in: current_user.county_ids}
    end

    def resource
      val = super
      @_resource ||= val.readonly? ? val.class.find(val.id) : val
    end

    def resource_params
      request.get? ? [] : [params.require(:person).permit(:first_name, :last_name, 
        county_memberships_attributes: [:id, :_destroy, :persistent, :county_id],
        position_memberships_attributes: [:id, :_destroy, :persistent, :position_id])]
    end
  end
end
