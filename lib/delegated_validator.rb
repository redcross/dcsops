class DelegatedValidator < SimpleDelegator
  class_attribute :target_class

  include ActiveRecord::Validations
  undef :errors

  def self.method_missing(method_name, *args, &block)
    self.target_class.__send__(method_name, *args, &block)
  end

  def self.valid?(target, context)
    self.new(target).valid?(context)
  end

end