module Core
  module SerializedColumns
    module ClassMethods
      def serialized_accessor(store_attribute, name, type, default: nil)
        column = SerializedColumn.new(name.to_s, default, type)

        serialized_columns[name] = [store_attribute, column]

        serialized_columns_warning = -> { ActiveSupport::Deprecation.warn("SerializedColumns is currently stubbed out, this method is a no-op") }

        define_method name do
          serialized_columns_warning.call
          nil
        end

        define_method :"#{name}_before_type_cast" do
          serialized_columns_warning.call
          nil
        end

        define_method :"#{name}=" do |val|
          serialized_columns_warning.call
          nil
        end

        scope :"with_#{name}_present", -> do
          serialized_columns_warning.call
          none
        end

        scope :"with_#{name}_value", ->(val) do
          serialized_columns_warning.call
          none
        end
      end
    end
  end
end
