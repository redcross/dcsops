module Paginatable
  def should_paginate?; params[:page] != 'all'; end

  def collection
    @collection_with_pagination ||= begin
      scope = super
      scope = scope.page(params[:page]) if should_paginate?
      scope
    end
  end
end