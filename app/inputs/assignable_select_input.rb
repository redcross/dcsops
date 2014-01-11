module AssignableSelect
  extend ActiveSupport::Concern

  include ActionView::Helpers::FormOptionsHelper
  def collection
    if object.respond_to? humanized_method
      humanized_collection
    else
      assignable_collection
    end
  end

  def humanized_method
    options[:humanized] || "humanized_#{method.to_s.pluralize}"
  end

  def humanized_collection
    options_from_collection_for_select(object.send(humanized_method), :value, :humanized, object.send(method))
  end

  def assignable_collection
    options_from_collection_for_select(object.send("assignable_#{method.to_s.pluralize}"), :id, :humanized, object.send("#{method}_id"))
  end

end

class AssignableSelectInput <  FormtasticBootstrap::Inputs::SelectInput
  include AssignableSelect
end

class AssignableSelectAdminInput < Formtastic::Inputs::SelectInput
  include AssignableSelect
end