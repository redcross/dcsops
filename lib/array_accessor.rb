module ArrayAccessor
  extend ActiveSupport::Concern

  module ClassMethods
    def array_accessor *syms
      syms.each do |sym|
        define_method "#{sym}_array" do |valid_options=nil|
          val = self.send(sym) || ''
          array = val.split(',').select(&:present?)
          array = (array & valid_options) if valid_options
          array
        end
      end
    end
  end
end
