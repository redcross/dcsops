ActiveAdmin.register Delayed::Job, as: 'Job' do
  menu parent: 'System'

  actions :all, except: [:edit, :update]

  scope :all do |scope|
    scope
  end

  scope :failing do |scope|
    scope.where.not(last_error: nil)
  end

  index do
    column :id
    column :priority
    column :attempts
    column :queue
    column :handler do |r|
      #r.handler.gsub(/password: .*$/, "password: --------")
      r.handler.split("\n").first
    end
    column :last_error
    column :run_at
    column :locked_at
    column :failed_at
    column :locked_by
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :priority
      row :attempts
      row :queue
      row :handler do |r|
        #r.handler.gsub(/password: .*$/, "password: --------")
        r.handler.split("\n").first
      end
      row :last_error
      row :run_at
      row :locked_at
      row :failed_at
      row :locked_by
      row :created_at
    end
  end
end