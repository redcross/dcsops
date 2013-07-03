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

    $(document).on 'click', 'button.address-lookup', (evt) =>
      evt.preventDefault();
      $('#incidents_dat_incident_search_for_address').blur()

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
      console.log show, $(".housing-collapse .collapse[data-show=#{show}]"), $(".housing-collapse .collapse[data-show!=#{show}]")
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



    $('.collapse').collapse({toggle: false})