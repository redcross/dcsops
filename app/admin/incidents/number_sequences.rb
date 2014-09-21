ActiveAdmin.register Incidents::NumberSequence, as: 'Number Sequence' do
  menu parent: 'Incidents'

  filter :name

  index do
    id_column
    column :name
    column :current_year
    column :current_number
    column :format
    column(:chapters) { |ns| safe_join(ns.chapters.map(&:name), tag(:br)) }
    actions
  end

  #index do
  #  column("CID") { |msg| msg.chapter_id }
  #  column :message_number
  #  column :incident_number
  #  column :county_name
  #  column :num_dials
  #  actions
  #end
#
  #show do |log|
  #  panel "Log" do
  #    table_for log.log_items.not_sms_internal do |li|
  #      column :action_at
  #      column :action_type
  #      column :recipient
  #      column :result
  #    end
  #  end
  #  default_main_content
  #end

  controller do
    def collection
      @col ||= super.preload{chapters}
    end
  end
end
