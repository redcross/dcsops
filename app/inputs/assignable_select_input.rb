class AssignableSelectInput <  FormtasticBootstrap::Inputs::SelectInput
  include ActionView::Helpers::FormOptionsHelper
  def collection
    options_from_collection_for_select(object.send("humanized_#{method}s"), :value, :humanized, object.send(method))
  end
end