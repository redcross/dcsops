module ActiveRecord
  module Sanitization
    extend ActiveSupport::Concern

    module ClassMethods
      def sanitize_sql_hash_for_conditions(attrs, default_table_name = self.table_name)
        attrs = expand_hash_conditions_for_aggregates(attrs)

        table = Arel::Table.new(table_name, arel_engine).alias(default_table_name)
        PredicateBuilder.build_from_hash(self, attrs, table).map { |b|
          connection.visitor.accept b
        }.join(' AND ')
      end
      alias_method :sanitize_sql_hash, :sanitize_sql_hash_for_conditions
    end
  end
end