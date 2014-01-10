class Incidents::PriceListItem < ActiveRecord::Base
  validates :item_class, :name, :unit_price, presence: true

  def calculate_total(quantity)
    unit_price * quantity
  end

  class Shelter < Incidents::PriceListItem
    def calculate_total(quantity)
      case quantity
      when 1..4 then 200
      when 5..8 then 400
      when 9..12 then 800
      when 13..16 then 1000
      when 17..20 then 1200
      else 0
      end
    end
  end

  class ShelterOneNight < Incidents::PriceListItem
    def calculate_total(quantity)
      case quantity
      when 1..4 then 100
      when 5..8 then 200
      when 9..12 then 300
      when 13..16 then 400
      when 17..20 then 500
      else 0
      end
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
