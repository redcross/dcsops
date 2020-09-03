module HasManyRoutesFor
  extend ActiveSupport::Concern

  module ClassMethods
    def has_many_routes_for *names
      names = names.flatten
      names.each do |name|
        name = name.to_s
        generate_url_and_path_helpers(nil, :"resource_#{name}", [:incidents, :region, :incident, name], [:@region, :@incident])
        helper_method :"resource_#{name}_path"

        name = name.singularize
        actions = [nil, :edit, :new]
        actions.each do |action|
          ivars = [:@region, :@incident, nil]

          generate_url_and_path_helpers(action, :"resource_#{name}", [:incidents, :region, :incident, name], ivars)
          helper_method :"#{action ? "#{action}_" : ''}resource_#{name}_path"
        end
      end
    end
  end
end