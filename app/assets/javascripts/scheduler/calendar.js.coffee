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
      date = $(evt.target).val()
      period = $(evt.target).data('period')
      shift = $(evt.target).attr('name')
      register = $(evt.target).is(':checked')
      assignment = $(evt.target).data('assignment')
      body = 
        date: date
        shift_id: shift
        person_id: @person || @params.person_id
      $.ajax
        url: '/scheduler/shift_assignments' + (if register then '' else '/'+assignment)
        data: JSON.stringify(if register then body else {})
        dataType: 'json'
        contentType: 'application/json'
        type: if register then 'POST' else 'DELETE'
        complete: (xhr, status) =>
          this.reloadDate(date, period)

    $('#select-person').typeahead
      source: (query, process) =>
        $.ajax
          dataType: 'json'
          data:
            name_query: query
          url: '/roster/people'
          success: (data) =>
            @people = {}
            processed = data.map (el) => 
              key = el.first_name + " " + el.last_name
              @people[key] = el
              key
            process(processed)
      updater: (item) =>
        @person = @people[item].id
        this.reloadMonth()
        item

    $('#clear-person').click (evt) =>
      $('#select-person').val('')
      @person = null
      this.reloadMonth()

    $(document).on 'click', '#highlighting-group > button', (evt) =>
      active = if ($(evt.target).hasClass('active')) then false else true
      $(evt.target).toggleClass('active', active)
      $('.calendar-container').toggleClass($(evt.target).data('style'), active)

    $(document).on 'click', '#select-shift-group > button', (evt) =>
      $('#select-shift-group > button').removeClass('active')
      chosen = $(evt.target).data('shifts')
      @params['show_shifts'] = chosen
      $('#select-shift-group > button[data-shifts='+chosen+']').addClass('active')
      $('#choose-counties').toggle(chosen == 'county')
      this.reloadMonth()

    $('#choose-county').change (evt) =>
      val = $(evt.target).val()
      @params['counties'] = if this.isArray(val) then val else [val]
      this.reloadMonth()

  renderArgs: () ->
    $.extend {}, @params,
      person_id: @person
      show_shifts: @show_shifts
      highlight: @highlight

  reloadShifts: () ->
    $.ajax
      url: @avail_url
      type: 'GET'
      data: this.renderArgs()
      success: (data) =>
        $('.open-shifts').html(data)

  reloadMonth: () ->
    this.reloadShifts()
    $.ajax
      url: '/scheduler/calendar/' + @month
      type: 'GET'
      data: this.renderArgs()
      success: (data) =>
        $('.calendar-container').html(data)

  reloadDate: (date, period) ->
    this.reloadShifts()
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