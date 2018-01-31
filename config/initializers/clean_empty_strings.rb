module CleanEmptyStrings
  extend ActiveSupport::Concern

  # def type_cast_for_write_with_nil_strings(value)
  #   if text?
  #     value = value.presence
  #   end
  #   type_cast_for_write_without_nil_strings value
  # end

  # included do
  #   alias_method_chain :type_cast_for_write, :nil_strings
  # end
end

ActiveRecord::ConnectionAdapters::Column.send(:include, CleanEmptyStrings)
ActiveRecord::ConnectionAdapters::PostgreSQLColumn.send(:include, CleanEmptyStrings)