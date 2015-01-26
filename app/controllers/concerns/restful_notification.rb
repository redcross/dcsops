module RESTfulNotification
  def update_resource(resource, args)
    super(resource, args).tap do |success|
      notify resource if success
    end
  end

  def create_resource resource
    super(resource).tap do |success|
      notify resource if success
    end
  end

  def destroy_resource resource
    super(resource).tap do |success|
      notify resource if success
    end
  end
end