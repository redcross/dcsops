# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class window.IncidentCaseController
  constructor: () ->
    $(document).on 'input change keyup', 'tr.case-assistance-item input, tr.case-assistance-item select', (evt) =>
      $target = $(evt.target)
      this.recalcRow($target.closest('tr.case-assistance-item'))
      this.recalcTotal()

  recalcRow: ($row) ->
    selected = $row.find('select.price-list-item :selected')
    unit = selected.data('unit-price')
    console.log selected, unit
    quantity = parseInt($row.find('input.quantity').val())

    subtotal = unit * quantity
    $row.find('input.subtotal').val (subtotal || "")

  recalcTotal: () ->
    subtotals = $('tr.case-assistance-item input.subtotal').map (idx, el) -> $(el).val()
    console.log subtotals
    total = subtotals.toArray().reduce ((accum, item) -> accum + (parseFloat(item) || 0)), 0

    $('input.total').val(total)