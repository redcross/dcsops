# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class window.IncidentCaseController
  constructor: () ->
    $(document).on 'input change keyup', 'tr.case-assistance-item input, tr.case-assistance-item select', (evt) =>
      $target = $(evt.target)
      this.recalcRow($target.closest('tr.case-assistance-item'))
      this.recalcTotal()
    $(document).on 'cocoon:after-remove', '#case-assistance-items, #case-assistance-items > tbody', (evt) =>
      this.recalcTotal()

  recalcRow: ($row) ->
    selected = $row.find('select.price-list-item :selected')
    unit = selected.data('unit-price')
    type = selected.data('type')
    console.log selected, unit
    quantity = parseInt($row.find('input.quantity').val())

    subtotal = if type == 'Incidents::PriceListItem::Shelter'
      this.calculateShelter(quantity)
    else if type == 'Incidents::PriceListItem::ShelterOneNight'
      this.calculateShelterOneNight(quantity)
    else if type == 'Incidents::PriceListItem::Food'
      this.calculateFood(quantity)
    else
      unit * quantity

    $row.find('input.subtotal').val (subtotal || "")

  recalcTotal: () ->
    subtotals = $('tr.case-assistance-item input.subtotal').map (idx, el) -> $(el).val()
    console.log subtotals
    total = subtotals.toArray().reduce ((accum, item) -> accum + (parseFloat(item) || 0)), 0

    $('input.total').val(total)

  calculateFood: (quantity) ->
    if quantity == 0
      0
    else if quantity == 1
      50
    else
      35 + (quantity * 20)

  calculateShelter: (quantity) ->
    if quantity <= 0
      0
    else if quantity <= 4
      200
    else if quantity <= 8
      400
    else if quantity <= 12
      800
    else if quantity <= 16
      1000
    else if quantity <= 20
      1200
    else 0

  calculateShelterOneNight: (quantity) ->
    if quantity <= 0
      0
    else if quantity <= 4
      100
    else if quantity <= 8
      200
    else if quantity <= 12
      300
    else if quantity <= 16
      400
    else if quantity <= 20
      500
    else 0