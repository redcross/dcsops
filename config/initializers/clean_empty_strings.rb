module ActiveRecord
  module Type
    class String < Value
      def type_cast_for_database(value)
        super(value.presence)
      end
    end
  end
end
