ActiveAdmin.register Roster::Person, as: 'Person' do
  batch_action :destroy, false
  batch_action :edit, false

  actions :all, except: [:destroy]

  menu parent: 'Roster'

  index do
    column("CID") {|p| p.region_id }
    column :name_last_first, sortable: "last_name"
    column :username
    column :last_login

    actions do |person|
      link_to "Impersonate", impersonate_scheduler_admin_person_path(person), {method: :post} if authorized?(:impersonate, person)
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :first_name
      f.input :last_name
      f.input :rco_id
    end
    f.actions
    f.inputs do
      f.has_many :shift_territory_memberships do |shift_territory_form|
        shift_territory_form.input :shift_territory, collection: (f.object.region && f.object.region.shift_territories)
        shift_territory_form.input :persistent
        shift_territory_form.input :_destroy, as: :boolean, label: "Remove"
      end
    end
    f.actions
    f.inputs do
      f.has_many :position_memberships do |form|
        form.input :position, collection: (f.object.region && f.object.region.positions)
        form.input :persistent
        form.input :_destroy, as: :boolean, label: "Remove"
      end
    end
    f.actions
  end

  show do |person|
    attributes_table do
      attrs = %i(id region primary_shift_territory full_name email last_login vc_imported_at vc_is_active gap_primary gap_secondary gap_tertiary vc_last_login vc_last_profile_update address1 address2 city state zip lat lng rco_id)
      attrs.each do |a|
        row a
      end
    end
    
    columns do
      column do
        panel "Positions" do
          table_for person.position_memberships do
            column( :name) { |rec| rec.position && rec.position.name }
            column(:persistent) { |rec| rec.persistent ? 'Yes' : ''}
            column(:capabilities) {|rec| safe_join rec.position.capability_memberships.map(&:display_name),  tag(:br)}
          end
        end
      end
      column do
        panel "Shift Territories" do
          table_for person.shift_territory_memberships do
            column( :name) { |rec| rec.shift_territory && rec.shift_territory.name }
            column(:persistent) { |rec| rec.persistent ? 'Yes' : ''}
          end
        end
      end
    end
  end

  scope :default, default: true do |scope|
    scope
  end

  scope :logins do |scope|
    scope.order(last_login: :desc).where.not(last_login: nil)
  end

  member_action :impersonate, method: [:post, :delete] do
    #p = resource
    #p.reset_persistence_token! if p.persistence_token.blank?
    #sess = Roster::Session.create!(p, true)
    if request.post?
      session[:impersonating_user_id] = resource.id
      redirect_to '/'
    else
      session[:impersonating_user_id] = nil
      redirect_back fallback_location: root_path
    end
  end
  action_item :possess, only: :show, if: proc{ authorized? :impersonate, resource} do
    link_to "Possess", url_for(action: :impersonate, only_path: true), {method: :post}
  end
  action_item :vc, only: :show do
    link_to "Volunteer Connection", resource.vc_profile_url
  end


  filter :first_name
  filter :last_name
  filter :shift_territories_id, :as => :check_boxes, :collection => proc {current_region.shift_territories.enabled}
  filter :positions_id, as: :check_boxes, collection: proc {current_region.positions.visible}
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

    before_action only: :index do
      #params['q'] ||= {shift_territories_id_in: current_user.shift_territory_ids}
    end

    def resource
      val = super
      @_resource ||= val.readonly? ? val.class.find(val.id) : val
    end

    def resource_params
      [params.fetch(resource_request_name, {}).permit(:first_name, :last_name, :rco_id,
        shift_territory_memberships_attributes: [:id, :_destroy, :persistent, :shift_territory_id],
        position_memberships_attributes: [:id, :_destroy, :persistent, :position_id])]
    end
  end
end
