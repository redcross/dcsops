require 'authlogic/controller_adapters/rack_adapter'

Scheduler::Application.routes.draw do

  puts ARGV.join
  break if ARGV.join.include? 'assets:' # this prevents triggering ActiveAdmin during precompile

  ActiveAdmin.routes(self)

  filter = lambda{|req| 
    rack_req = Rack::Request.new req.env
    rack_req.instance_eval do
      def request; self; end
      def remote_ip; self.ip; end
    end
    Authlogic::Session::Base.controller = Authlogic::ControllerAdapters::AbstractAdapter.new(rack_req)
    ret = Roster::Session.find.nil?
    Authlogic::Session::Base.controller = nil
    if ret
      req.env['SET_RETURN_TO'] = '/'
    end
    ret
  }

  root to: "roster/sessions#new", constraints: filter
  root to: "root#index", constraints: lambda{|req| !filter.call(req)}, as: nil

  namespace :scheduler do
    root to: "home#root"
    get :on_call, controller: 'home'
    resources :shifts, only: [:index] do
      match '', via: [:put], action: :update_shifts, on: :collection
    end
    resources :shift_groups

    get 'calendar/:year/:month(/:display)',  year: /\d{4}/, 
                                  month: /(january|february|march|april|may|june|july|august|september|october|november|december)/,
                                  to: 'calendar#show',
                                  as: 'calendar'
    get 'calendar/:date', date: /\d{4}-\d{2}-\d{2}/, to: 'calendar#day', as: 'calendar_day'
    get 'calendar/:month', month: /\d{4}-\d{2}/, to: 'calendar#day'

    resources :shift_assignments do
      match :swap, on: :member, via: [:get, :post]
    end
    resources :notification_settings, only: [:show, :update] do
      get :me, on: :collection
    end
    resources :flex_schedules, only: [:index, :show, :update]
    resources :people do
      resources :shift_assignments
    end
    resources :dispatch_config, except: [:new, :create, :destroy]
  end

  namespace :roster do
    #resources :chapters
    #resources :positions
    #resources :counties
    resources :people
    resource :session
    #resources :cell_carriers

    scope :openid, controller: 'open_id', path: 'openid', as: 'openid' do
      get 'user/:user_id', action: :user, as: :user
      match 'id', via: [:get, :post], action: :service
      match 'endpoint', via: [:get, :post], as: :endpoint, action: :endpoint
    end
  end

  namespace :incidents do
    root to: "home#root"
    match 'map', via: [:get, :post], to: "home#map"
    get :operations, to: "home#operations"
    resources :incidents do
      resource :dat, controller: :dat_incidents
      resources :event_logs
      
      collection do
        get :needs_report
        get :tracker
        match :link_cas, via: [:get, :post], as: :link_cas
      end
    end
    resources :dat_incidents, only: [:new, :create]
    resources :cas_incidents do
      resources :cases, controller: 'cas_cases' do
        get :narrative, on: :member
      end
    end
    scope "notification_subscriptions", as: :notification_subscription do
      resources :weekly, controller: 'notification_subscriptions', notification_type: 'weekly'
    end
  end

  match 'import/:import_secret/:provider/cas-v:version', via: [:head, :post], to: 'incidents/import#import_cas', version: /\d+/
  match 'import/:import_secret/:provider/vc-v:version', via: [:head, :post], to: 'roster/import#import_vc', version: /\d+/
  match 'import/:import_secret/:provider/deployment-v:version', via: [:head, :post], to: 'incidents/import#import_deployment', version: /\d+/
  match 'import/:import_secret/:provider/dispatch-v:version', via: [:head, :post], to: 'incidents/import#import_dispatch', version: /\d+/
end
