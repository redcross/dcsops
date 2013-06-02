Scheduler::Application.routes.draw do
  break if ARGV.join.include? 'assets:precompile' # this prevents triggering ActiveAdmin during precompile

  ActiveAdmin.routes(self)
  root to: "root#index"

  namespace :scheduler do
    root to: "home#root"
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
    resources :chapters
    resources :positions
    resources :counties
    resources :people
    resource :session
    resources :cell_carriers

    scope :openid, controller: 'open_id', path: 'openid', as: 'openid' do
      get 'user/:user_id', action: :user, as: :user
      match 'id', via: [:get, :post], action: :service
      match 'endpoint', via: [:get, :post], as: :endpoint, action: :endpoint
    end
  end
end
