class FormProxy
  instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id$)/ }

  attr_reader :keys

  def initialize(target)
    @target = target
    @keys = []
  end

  def input(*args)
    @keys << args.first
    target.send :input, *args
  end

  def semantic_fields_for(*args, &block)
    name = args.first
    target.semantic_fields_for *args do |new_builder|
      deep_proxy = FormProxy.new(new_builder)
      ret = block.call(deep_proxy)
      deep_proxy.keys.each {|deep_key| @keys << :"#{name}.#{deep_key}"}
      ret
    end
  end

  def semantic_errors(*args)
    @keys += args
    target.semantic_errors(*args)
  end
  #alias_method :fields_for, :semantic_fields_for

  protected
    def method_missing(name, *args, &block)
      target.send(name, *args, &block)
    end

    def target
      @target ||= []
    end
end