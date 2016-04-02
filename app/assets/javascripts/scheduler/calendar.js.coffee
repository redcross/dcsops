# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class window.CalendarController
  isArray: Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

  constructor: (params, avail_url, month) ->
    @month = month
    @params = params
    @avail_url = avail_url
    $(document).on 'click', 'input.shift-checkbox', (evt) =>
      $target = $(evt.target)
      date = $target.val()
      period = $target.data('period')
      shift = $target.attr('name')
      register = $target.is(':checked')
      assignment = $target.data('assignment')
      body = $target.data('params')
      $.ajax
        url: '/scheduler/shift_assignments' + (if register then '' else '/'+assignment)
        data: JSON.stringify(if register then body else {})
        dataType: 'json'
        contentType: 'application/json'
        type: if register then 'POST' else 'DELETE'
        complete: (xhr, status) =>
          this.reloadDate(date, period)

    new PersonTypeaheadController $('#select-person'), ((id, record) => @params.person_id = id; this.reload()), 'select-person',
      active: false
      has_position: true

    $(document).on 'click', '#highlighting-group > button', (evt) =>
      active = if ($(evt.target).hasClass('active')) then false else true
      $(evt.target).toggleClass('active', active)
      style = $(evt.target).data('style')
      if style == 'highlight-recommended-shifts'
        this.highlightRecommendedShifts(active)
      else
        $('.calendar-container').toggleClass($(evt.target).data('style'), active)

    $(document).on 'click', '#select-shift-group > button', (evt) =>
      $('#select-shift-group > button').removeClass('active')
      chosen = $(evt.target).data('shifts')
      @params['show_shifts'] = chosen
      $('#select-shift-group > button[data-shifts='+chosen+']').addClass('active')
      $('#choose-counties').toggle(chosen == 'county')
      this.reload()

    $('#choose-county').change (evt) =>
      val = $(evt.target).val()
      @params['counties'] = if this.isArray(val) then val else [val]
      this.reload()

    $(document).on 'change', '.choose-category', (evt) =>
      val = this.checkboxValues($('input.choose-category'))
      @params['categories'] = val
      this.reload()

  checkboxValues: (selector) ->
    val = []
    selector.each (idx, el) ->
      if $(el).is(':checked')
        val[val.length] = $(el).val()
    val

  highlightRecommendedShifts: (toggleIndicator) ->
    ###
    if toggleIndicator true
      get all of the
    ###
    console.log("highlighting with " + toggleIndicator);

  renderArgs: () ->
    @params

  reload: () ->
    args = this.renderArgs()
    this.reloadShifts(args)
    this.reloadMonth(args)

  reloadShifts: (params) ->
    $.ajax
      url: @avail_url
      type: 'GET'
      data: params
      success: (data) =>
        $('.open-shifts').html(data)

  reloadMonth: (params) ->
    $('.calendar-container table').addClass('loading').find('input[type=checkbox]').attr('disabled', true)
    $.ajax
      url: '/scheduler/calendar/' + @month
      type: 'GET'
      data: params
      success: (data) =>
        $('.calendar-container').html(data)

  reloadDate: (date, period) ->
    this.reloadShifts(this.renderArgs())
    $.ajax
      url: '/scheduler/calendar/' + date
      type: 'GET'
      data: $.extend(this.renderArgs(), {period: period})
      success: (data) =>
        switch period
          when 'week'
            $('tbody[data-week=' + date + ']').html(data)
          when 'monthly'
            $('.month').html(data)
          else
            $('.day[data-day=' + date + ']').html(data)
