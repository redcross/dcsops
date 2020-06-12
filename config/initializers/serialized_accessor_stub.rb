module Core
  module SerializedColumns
    module ClassMethods
      def serialized_accessor(store_attribute, name, type, default: nil)
        column = SerializedColumn.new(name.to_s, default, type)

        serialized_columns[name] = [store_attribute, column]

        define_method name do
        end

        define_method :"#{name}_before_type_cast" do
        end

        define_method :"#{name}=" do |val|
        end

        scope :"with_#{name}_present", -> do
          none
        end

        scope :"with_#{name}_value", ->(val) do
          none
        end
      end
    end
  end
end
