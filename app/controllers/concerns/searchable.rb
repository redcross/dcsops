module Searchable
  extend ActiveSupport::Concern

  def default_search_params
    {}
  end

  def search_params
    args = params[:q] || {}
    default_search_params.merge(args)
  end

  def search
    @search ||= resource_class.search(search_params)
  end

  def collection
    super.merge(search.result)
  end

  included do
    helper_method :search
  end
    
end