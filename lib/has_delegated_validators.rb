module HasDelegatedValidators
  extend ActiveSupport::Concern

  module ClassMethods
    def delegated_validator(klass, *opts)
      opts = opts.reduce(&:merge) || {}
      self.delegated_validators << {klass: klass, opts: opts}
    end

    def validators_on(*attrs)
      super(*attrs) + self.delegated_validators.flat_map{|d| d[:klass].validators_on(*attrs)}
    end
  end

  included do
    class_attribute :delegated_validators
    self.delegated_validators = []
  end

  def enabled_delegated_validators
    self.class.delegated_validators.select{|v| v[:opts][:if].nil? || HasDelegatedValidators.evaluate_option(self, v[:opts][:if]) }
  end

  def run_validations!
    super
    enabled_delegated_validators.each{|d| d[:klass].valid?(self, self.validation_context)}
  end

  def self.evaluate_option(record, option)
    case option
    when NilClass, TrueClass, FalseClass then option
    when Symbol then record.send(option)
    when Proc then record.instance_exec(&option)
    else raise "Illegal option type: #{option.inspect}"
    end
  end
end