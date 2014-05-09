class GridController < ApplicationController
  respond_to :html, :js
  inherit_resources

  actions :index, :update, :create

  def update
    update! do |fmt|
      fmt.js { render action: 'update' }
    end
  end

  def create
    create! do |fmt|
      fmt.js { render action: 'update' }
    end
  end

  class_attribute :columns
  def self.column *args
    self.columns ||= []
    self.columns << Column.new(*args)
  end

  def columns
    self.class.columns
  end
  helper_method :columns

  Column = Struct.new(:name, :form_options)

  def form_path(resource)
    resource.persisted? ? resource_path(resource) : collection_path
  end
  helper_method :form_path
end