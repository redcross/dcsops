module Exposure
  extend ActiveSupport::Concern

  module ClassMethods
    def expose(name, &block)
      ivar_name = "@" + name.to_s
      define_method(name) do
        instance_variable_get(ivar_name) || instance_variable_set(ivar_name, self.instance_eval(&block))
      end
      helper_method name if respond_to?(:helper_method)
    end
  end

end
