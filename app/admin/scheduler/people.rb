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
      link_to "Impersonate", impersonate_scheduler_admin_person_path(person), {method: :post} if authorized?(:impersonate, person)
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :first_name
      f.input :last_name
    end
    f.actions
    f.inputs do
      f.has_many :county_memberships do |county_form|
        county_form.input :county, collection: (f.object.chapter && f.object.chapter.counties)
        county_form.input :persistent
        county_form.input :_destroy, as: :boolean, label: "Remove"
      end
    end
    f.actions
    f.inputs do
      f.has_many :position_memberships do |form|
        form.input :position, collection: (f.object.chapter && f.object.chapter.positions)
        form.input :persistent
        form.input :_destroy, as: :boolean, label: "Remove"
      end
    end
    f.actions
  end

  show do |person|
    attributes_table do
      attrs = %i(id chapter primary_county full_name email last_login vc_imported_at vc_is_active gap_primary gap_secondary gap_tertiary vc_last_login vc_last_profile_update address1 address2 city state zip lat lng)
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

  scope :logins do |scope|
    scope.uniq.order{last_login.desc}.where{last_login != nil}
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
      redirect_to :back
    end
  end
  action_item only: :show, if: proc{ authorized? :impersonate, resource} do
    link_to "Possess", url_for(action: :impersonate, only_path: true), {method: :post}
  end
  action_item only: :show do
    link_to "Volunteer Connection", resource.vc_profile_url
  end


  filter :first_name
  filter :last_name
  filter :counties_id, :as => :check_boxes, :collection => proc {current_chapter.counties}
  filter :positions_id, as: :check_boxes, collection: proc {current_chapter.positions.sort_by{|i| [i.hidden ? 1 : 0, i.name]}}
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
