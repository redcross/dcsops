module HasManyRoutesFor
  extend ActiveSupport::Concern

  module ClassMethods
    def has_many_routes_for *names
      names = names.flatten
      names.each do |name|
        name = name.to_s
        generate_url_and_path_helpers(nil, :"resource_#{name}", [:incidents, :chapter, :incident, name], ['@chapter', '@incident'])
        helper_method :"resource_#{name}_path"

        name = name.singularize
        actions = [nil, :edit, :new]
        actions.each do |action|
          if action == :new
            ivars = ['@chapter', '(given_args.first || @incident)']
          else
            ivars = ['@chapter', '@incident', 'nil']
          end
          generate_url_and_path_helpers(action, :"resource_#{name}", [:incidents, :chapter, :incident, name], ivars)
          helper_method :"#{action ? "#{action}_" : ''}resource_#{name}_path"
        end
      end
    end
  end
end