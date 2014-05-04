# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class window.DatIncidentsFormController
  responderCount: 0

  constructor: () ->
    $(document).on 'click', '.add-responder', (evt) =>
      evt.preventDefault()

      table = $(evt.target).parents('table')

      id = new Date().getTime() + @responderCount++
      template_str = $(table).data('template').replace(/_new_responder_assignment/g, "_#{id}").replace(/\[new_responder_assignment\]/g, "[#{id}]")
      template = $(template_str)
      $(table).find('tbody').append(template)

      window["incidents_dat_incident_incident_attributes_responder_assignments_attributes_#{id}_person_id_typeahead"].selected = $(evt.target).data('person-text')

      ['person_id', 'person_text'].forEach (field) =>
        el = $(template).find("[name*=#{field}]")
        val = $(evt.target).data(field.replace('_', '-'))

        el.val(val)

      $(template).find("[name*=was_flex]").attr('checked', $(evt.target).data('was-flex'))



    $(document).on 'click', '.add-vehicle', (evt) =>
      evt.preventDefault()
      id = $('#vehicles').val()
      return if id==''
      name = $('#vehicles :selected').text()
      tmpl = $(evt.target).data('template')
      dom = $.parseHTML(tmpl)

      $(dom).find('.vehicle-name').text(name)
      $(dom).find('input').val(id)

      $(evt.target).parents('.control-group').before(dom)
      $("#vehicles").val('')

    $(document).on 'click', '.remove-vehicle', (evt) =>
      evt.preventDefault()

      $(evt.target).parents('.control-group').remove()

    #$(document).on 'change', 'input.meal-check', (evt) =>
    #  cmd =  ($(evt.target).is(':checked') && 'show' || 'hide')
    #  $(evt.target).parents('.control-group').next('.collapse').collapse(cmd)
#
    #$(document).on 'change', 'input.services-other-translation', (evt) =>
    #  cmd =  ($(evt.target).is(':checked') && 'show' || 'hide')
    #  console.log cmd
    #  $('.languages').collapse(cmd)

    $(document).on 'change', 'input[data-bind]', (evt) =>
      cmd =  ($(evt.target).is(':checked') && 'show' || 'hide')
      $($(evt.target).data('bind')).collapse(cmd)

    $(document).on 'scroll', (evt) =>
      isFixed = ($(window).scrollTop() > 80)
      $('.tabbable ul.nav').toggleClass 'fixed', isFixed
      #$('.tabbable ul.nav').toggleClass 'nav-pills', isFixed

    $(document).on 'click', '.btn-group.single-choice button', (evt) =>
      evt.preventDefault()
      $(evt.target).siblings().toggleClass('active', false)
      $(evt.target).toggleClass('active', true)

    $(document).on 'click', '.housing buttonasdf', (evt) =>
      evt.preventDefault()
      show = $(evt.target).data('show')
      #console.log show, $(".housing-collapse .collapse[data-show=#{show}]"), $(".housing-collapse .collapse[data-show!=#{show}]")
      $(".housing-collapse .collapse[data-show=#{show}]").collapse('show')
      $(".housing-collapse .collapse[data-show!=#{show}]").collapse('hide')

    $(document).on 'click', '[data-hide], [data-show]', (evt) =>
      data = $(evt.target).data()
      shown = ''
      if (data.show)
        shown = $(data.show)
        shown.collapse('show')
      if (data.hide)
        $(data.hide).not(shown).collapse('hide')

    @da_fields = ['incidents_dat_incident_units_affected', 'incidents_dat_incident_units_minor', 'incidents_dat_incident_units_major', 'incidents_dat_incident_units_destroyed']
    $(document).on 'change', @da_fields.map((el)->"##{el}").join(","), (evt) =>
      total = 0
      @da_fields.forEach (el) ->
        console.log(total, $("##{el}").val())
        total += Number($("##{el}").val())
      $('#incidents_dat_incident_units_total').val(total)

    $(document).on 'click', '[data-toggle=remote-tab]', (evt) =>
      $target = $(evt.target)
      href = $target.data('target')
      $("[data-target=#{href}][data-toggle=tab]").tab('show')

    $('.collapse').collapse({toggle: false})


