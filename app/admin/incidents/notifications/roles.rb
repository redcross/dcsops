ActiveAdmin.register Incidents::Notifications::Role, as: 'Notification Role' do
  batch_action :destroy, false
  batch_action :edit, false

  actions :all, except: [:destroy]

  menu parent: 'Incidents'

  index do 
    id_column
    column :chapter_id
    column :name
    column(:members) { |r|
      (r.positions.map(&:name) + r.shifts.map(&:name)).join ", "
    }
    default_actions
  end

  form do |f|
    f.inputs
    f.inputs do
      f.has_many :triggers, allow_destroy: true do |rf|
        rf.input :event
        rf.input :template, as: :assignable_select_admin
        rf.input :use_sms
      end
      f.has_many :role_scopes, allow_destroy: true do |sf|
        sf.input :level, as: :assignable_select_admin
        sf.input :value
      end
    end
    f.inputs do
      f.input :positions, as: :check_boxes, collection: (f.object.chapter.try(:positions) || [])
      f.input :shifts, as: :check_boxes, collection: Scheduler::Shift.for_chapter(f.object.chapter)
    end
    f.actions
  end

  show do |role|
    default_main_content
    columns do
      column do
        panel "Bindings" do
          table_for role.role_scopes do
            column("Scope") { |s| s.humanized_level }
            column :value
          end
          table_for role.positions do
            column("Position") { |p| p.name }
          end
          table_for role.shifts do
            column("Shift") { |s| s.name }
            column("Shift Group") { |shift| shift.shift_group.name }
          end
        end
      end
      column do
        panel "Triggers" do
          table_for role.triggers.joins{event}.order{event.ordinal} do
            column :event
            column(:template) { |t| t.humanized_template }
            column :use_sms
          end
        end
      end
    end
    columns do
      column do
        panel "Current Position Members" do
          table_for role.position_members do
            column :full_name
            column :email
            column :sms do |person|
              person.sms_addresses.first
            end
          end
        end
      end
      column do
        panel "Current Shift Members" do
          table_for role.shift_member_assignments do
            column('Shift') { |ass| ass.shift.name }
            column('Person') { |ass| ass.person.full_name }
            column('Email') { |ass| ass.person.email }
            column('SMS') { |ass| ass.person.sms_addresses.first }
          end
        end
      end
    end
  end

  controller do

    def collection
      @col ||= super.includes{[positions,shifts]}
    end

    def resource_params
      request.get? ? [] : [params.require(:notification_role).permit(:name, :chapter_id, position_ids: [], shift_ids: [], triggers_attributes: [:id, :event_id, :template, :use_sms, :_destroy], role_scopes_attributes: [:id, :_destroy, :level, :value])]
    end
  end
end
