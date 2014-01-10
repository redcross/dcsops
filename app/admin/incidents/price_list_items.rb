ActiveAdmin.register Incidents::PriceListItem, as: 'Price List Item' do
  menu parent: 'Incidents'

  form do |f|
    f.inputs do
      f.input :item_class
      f.input :name
      f.input :unit_price
      f.input :type, collection: options_for_select(available_types, selected: f.object.type), include_blank: false
      f.input :description
    end
    f.actions
  end

  controller do
    def resource_params
      request.get? ? [] : [params.require(:price_list_item).permit!]
    end
    helper do
      def available_type_classes
        Incidents::PriceListItem.subclasses
      end

      def available_types
        [['Default', '']] + available_type_classes.map do |klass|
          [klass.to_s.split(/::/).last, klass.to_s]
        end
      end
    end
  end
end
