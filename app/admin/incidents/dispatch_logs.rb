ActiveAdmin.register Incidents::DispatchLog, as: 'Dispatch Log' do
  menu parent: 'Incidents'

  actions :index, :show

  filter :region
  filter :incident_number
  filter :county
  filter :created_at

  index do
    column("CID") { |msg| msg.region_id }
    column :message_number
    column :incident_number
    column :county
    column :num_dials
    actions
  end

  show do |log|
    panel "Log" do
      table_for log.log_items.not_sms_internal do |li|
        column :action_at
        column :action_type
        column :recipient
        column :result
      end
    end
    default_main_content
  end

  controller do
    def collection
      @col ||= super.includes(:log_items)
    end
  end
end
