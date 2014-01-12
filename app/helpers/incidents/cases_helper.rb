module Incidents::CasesHelper
  def price_list_description(item)
    [item.item_class, item.name, item.type.nil? ? number_to_currency(item.unit_price) : nil].compact.join " - "
  end

  def price_list_options(list, selected)
    options_for_select(list.map{|item| [price_list_description(item), item.id, {data: {type: item.type, unit_price: item.unit_price}}] }, selected)
  end
end
