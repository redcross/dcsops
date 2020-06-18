# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class window.SwapController
  constructor: (shift_territory_id, position_ids) ->

    filter = 
      in_shift_territory: shift_territory_id
      with_position: position_ids

    new PersonTypeaheadController $('#select-person'), ((id, record) => $("#swap-to-id").val(id)), 'shift-swap', filter