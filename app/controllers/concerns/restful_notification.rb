module RESTfulNotification
  def update_resource(resource, args)
    super resource, args
    notify resource
  end

  def create_resource resource
    super resource
    notify resource
  end

  def destroy_resource resource
    super resource
    notify resource
  end
end