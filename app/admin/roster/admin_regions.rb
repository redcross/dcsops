ActiveAdmin.register Roster::Region, as: 'Region Admin' do
  menu parent: 'Roster', if: ->{authorized? :read, AdminAbility::RegionAdminProxy}, label: 'Region Admin'

  actions :index, :show, :edit, :update

  filter :name

  controller do
    def resource
      @region ||= begin
        region = end_of_association_chain.find_by_slug params[:id]
        authorize_resource! region
        region
      end
    end

    def scoped_collection
      Roster::Region.where(id: current_user.region_id)
    end

    def apply_authorization_scope scope
      scope
    end

    def authorized? action, subject=nil
      subject = AdminAbility::RegionAdminProxy.new(subject) if Roster::Region === subject || Roster::Region == subject
      super(action, subject)
    end

    helper do
      def vc_client
        @client ||= begin
          client = Vc::Client.new(resource.vc_username, resource.vc_password)
          client.login!
          client
        rescue Vc::Client::InvalidCredentials
          nil
        end
      end

      def vc_permissions
        @permissions ||= vc_client && vc_client.permissions.available_unit_config_permissions
      end

      def cas_client
        @cas_client ||= begin
          if resource.cas_username.present?
            client = Cas::Client.new(resource.cas_host, resource.cas_username, resource.cas_password)
            client.login!
            client
          end
        rescue Cas::Client::InvalidCredentials
          nil
        end
      end
    end
  end

  permit_params :vc_username, :vc_password, :cas_username, :cas_password, :scheduler_flex_day_start, :scheduler_flex_night_start

  show do
    attributes_table do
      row :vc_username
      row('Account Valid?') { vc_permissions.present? ? 'Yes' : 'No' }
      if vc_client.present?
        row('Has Query Tool Admin Permission') { vc_permissions.include?('Query Tool') ? 'Yes' : 'No' }
        row('Has Hours Manager Admin')  { vc_permissions.include?('Hours Manager') ? 'Yes' : 'No' }
        row('Has Disaster Workforce Admin') { vc_client.permissions.has_disaster_management_permission? ? 'Yes' : 'No' }
      end
    end
    attributes_table do
      row :cas_username
      row :cas_host
      row('Account Valid?') { cas_client.present? ? 'Yes' : 'No' }
    end
    attributes_table do
      row :scheduler_flex_day_start
      row :scheduler_flex_night_start
    end
  end

  form do |f|
    f.inputs 'Volunteer Connection' do
      f.input :vc_username
      f.input :vc_password, as: :string
    end

    f.inputs 'CAS' do
      f.input :cas_username
      f.input :cas_password, as: :string
    end

    f.inputs 'DCSOps Settings' do
      f.input :scheduler_flex_day_start, as: :time_offset
      f.input :scheduler_flex_night_start, as: :time_offset, midnight: true
    end

    f.actions
  end

  index do
    column :id
    column :name
    column :vc_username
    column :cas_username
    actions
  end
end
