# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class window.SwapController
  constructor: (county_id, position_ids) ->

    filter = 
      in_county: county_id
      with_position: position_ids

    new PersonTypeaheadController $('#select-person'), ((id, record) => $("#swap-to-id").val(id)), 'shift-swap', filter