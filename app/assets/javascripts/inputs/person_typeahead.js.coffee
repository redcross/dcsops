class window.PersonTypeaheadController
  constructor: (dom, callback, filter={}, @selected=null) ->
    @callback = callback

    # This ensures that if you select out of the typeahead without choosing
    # an item, the text box always represents the current data value, rather
    # than whatever random text the user had typed in.
    $(dom).blur (evt) =>
      $(dom).val @selected

    $(dom).typeahead
      source: (query, process) =>
        if query.length <= 2
          process([])
          return

        if @prev_query and query.indexOf(@prev_query) != -1
          process(@prev_data)
          return

        $.ajax
          dataType: 'json'
          data:
            $.extend filter,
              name_contains: query
          url: '/roster/people'
          success: (data) =>
            @people = {}
            processed = data.map (el) => 
              key = el.full_name
              @people[key] = el
              key

            @prev_query = query
            @prev_data = processed

            process(processed)
      updater: (item) =>
        @callback(@people[item].id, @people[item])
        @selected = item
        item