# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class window.ShiftsController
  constructor: () ->
    $(document).on 'click', '.clearbtn', (evt) ->
      $(evt.target).parents('td').find('input').val("")
    $(document).on 'change', '.all-shifts input', (evt) ->
      $(evt.target).parents('form').find('input.' + $(evt.target).data('all-class')).val($(evt.target).val())
    $(document).on 'click', '.all-shifts .clearallbtn', (evt) ->
      $(evt.target).parents('form').find('input.' + $(evt.target).data('all-class')).val("")