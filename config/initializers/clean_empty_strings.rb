module ActiveRecord
  module Type
    class String2 < Value
      def type_cast_for_database(value)
        super(value.presence)
      end
    end
  end
end
