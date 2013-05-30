ActiveAdmin.register Roster::Person, namespace: 'scheduler_admin', as: 'Person' do
  batch_action :destroy, false
  batch_action :edit, false

  index do
    column :name_last_first, sortable: "last_name"

    column "Number of Shifts" do |person|
      Scheduler::ShiftAssignment.where(person_id: person).where('date <= ?', Date.current).count
    end

    column "Last Shift" do |person|
      Scheduler::ShiftAssignment.where(person_id: person).where('date <= ?', Date.current).first.try(:date)
    end

    column "Next Shift" do |person|
      Scheduler::ShiftAssignment.where(person_id: person).where('date >= ?', Date.current).first.try(:date)
    end

    column :last_login

    default_actions
  end

  show do
    attributes_table
    columns do
      column do
        panel "Positions" do
          table_for person.positions do
            column :name
          end
        end
      end
      column do
        panel "Counties" do
          table_for person.counties do
            column :name
          end
        end
      end
    end
  end

  scope :default, default: true do |scope|
    scope.uniq
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

    def resource_params
      [params.require(:dispatch_config).permit(:is_active, :backup_first_id, :backup_second_id, :backup_third_id, :backup_fourth_id)]
    end
  end
end
