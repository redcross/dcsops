class Incidents::PriceListItem < ActiveRecord::Base
  def description
    "#{name} - #{unit_price}"
  end

  def calculate_total(quantity)
    unit_price * quantity
  end
end
