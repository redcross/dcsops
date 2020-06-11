class Incidents::PriceListItem < ApplicationRecord
  validates :item_class, :name, :unit_price, presence: true

  def self.enabled
    where(enabled: true)
  end

  def calculate_total(quantity)
    unit_price * quantity
  end

  class Shelter < Incidents::PriceListItem
    def calculate_total(quantity)
      unit_price * (quantity / 4.0).ceil
    end
  end

  class Food < Incidents::PriceListItem
    def calculate_total(quantity)
      case quantity
      when 0 then 0
      when 1 then 50
      else 35 + (quantity * 20)
      end
    end
  end

end
