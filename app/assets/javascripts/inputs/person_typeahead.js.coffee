class window.PersonTypeaheadController
  constructor: (dom, callback, @name, filter={}, @selected=null) ->
    @callback = callback

    # This ensures that if you select out of the typeahead without choosing
    # an item, the text box always represents the current data value, rather
    # than whatever random text the user had typed in.
    $(dom).blur (evt) =>
      $(dom).typeahead 'val', @selected

    taOpts = 
      highlight: true
      updater: (item) =>
        @callback(@people[item].id, @people[item])
        @selected = item
        item

    dsOpts =
      name: 'people'
      displayKey: 'full_name'
      source: (query, process) =>
        if query.length <= 2
          process([])
          return

        query = query.toLowerCase()

        if @prev_query and query.indexOf(@prev_query) != -1
          newData = @prev_data.filter (val) ->
            val.full_name.toLowerCase().indexOf(query) != -1
          console.log newData
          process(newData)
          return

        $.ajax
          dataType: 'json'
          data:
            $.extend filter,
              name_contains: query
          url: '/roster/people'
          success: (data) =>
            @people = {}

            @prev_query = query
            @prev_data = data

            process(data)

    $(dom).typeahead taOpts, dsOpts
    $(dom).on 'typeahead:selected', (evt, datum) =>
      console.log evt, evt.target, evt.target.value
      @callback(datum.id, datum)
      @selected = datum.full_name

    $(document).on 'click', "[data-clear-typeahead=#{@name}]", (evt) =>
      evt.preventDefault()
      $(dom).typeahead 'val', null
      @callback(null, null)
