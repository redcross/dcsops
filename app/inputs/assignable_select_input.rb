class AssignableSelectInput <  FormtasticBootstrap::Inputs::SelectInput
  include ActionView::Helpers::FormOptionsHelper
  def collection
    collection_method = options[:humanized] || "humanized_#{method}s"
    options_from_collection_for_select(object.send(collection_method), :value, :humanized, object.send(method))
  end
end