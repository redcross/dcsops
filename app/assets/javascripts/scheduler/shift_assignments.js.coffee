# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class window.SwapController
  constructor: (county_id, position_ids) ->
    $('#select-person').typeahead
      source: (query, process) =>
        $.ajax
          dataType: 'json'
          data:
            name_query: query
            in_county: county_id
            with_position: position_ids
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
        $("#swap-to-id").val(@person)
        item