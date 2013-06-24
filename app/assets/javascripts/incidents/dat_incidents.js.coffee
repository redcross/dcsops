# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class window.DatIncidentsFormController
  constructor: () ->
    $(document).on 'click', '.add-vehicle', (evt) =>
      evt.preventDefault()
      id = $('#vehicles').val()
      name = $('#vehicles :selected').text()
      tmpl = $(evt.target).data('template')
      dom = $.parseHTML(tmpl)

      $(dom).find('.vehicle-name').text(name)
      $(dom).find('input').val(id)

      $(evt.target).parents('.control-group').before(dom)

    $(document).on 'click', '.remove-vehicle', (evt) =>
      evt.preventDefault()

      $(evt.target).parents('.control-group').remove()