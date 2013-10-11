module ViewResourceMacros
  def has_resource(name, &block)
    before do
      # Creates the resource.  Use instance exec so the block can use helpers and lets defined on the example group.
      @resource ||= self.instance_exec(&block)
      # Assign to the symbol we wanted, so it's available in the view
      assign(name, @resource)
      # Assigns to @name so that we can use that in our assertions
      instance_variable_set("@#{name}", @resource)

      # If we pass an array, it's for stubing a collection, if not it's for stubbing a single object
      if @resource.is_a?(Array)
        view.stub(:collection) { @resource }
        view.stub(:resource_class) {@resource.first.class}
      else
        view.stub(:resource) {@resource}
        view.stub(:resource_class) {@resource.class}
      end
    end
  end
end

RSpec.configure do |config|
  config.extend ViewResourceMacros, :type => :view
end