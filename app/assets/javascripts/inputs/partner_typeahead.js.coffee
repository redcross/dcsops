class window.PartnerTypeaheadController
  canCreate: true
  createMessage: "Other/Not Listed"

  constructor: (dom, callback, filter={}) ->
    @callback = callback
    @dom = dom

    controller = this

    @dom.typeahead
      source: (query, process) =>
        if query.length <= 2
          process([])
          return

        if @prev_query and query.indexOf(@prev_query) != -1
          this.addNewItemRow(@prev_data, query, process)
          return

        $.ajax
          dataType: 'json'
          data:
            $.extend filter,
              name_contains: query
          url: '/partners/partners'
          success: (data) =>
            @list = {}
            
            processed = data.map (el) => 
              key = el.name
              @list[key] = el
              key

            @prev_query = query
            @prev_data = processed

            this.addNewItemRow(processed, query, process)

            process(processed)


      updater: (item) =>
        el = @list[item]
        if el
          @callback(@list[item].id, @list[item])
          this.setCreating(false)
        else if @canCreate
          @callback(null, null, item)
          this.setCreating(true)
        item

      highlighter: (item) =>
        el = @list[item]
        if el
          "#{el.name}<br /><small>#{el.address1}</small>"
        else "New Partner: #{item}"

  addNewItemRow: (serverData, name, process) ->
    console.log name, serverData
    arr = serverData.slice()
    arr.push(name)
    process(arr)

  setCreating: (val) ->
    cmd = val && 'show' || 'hide'
    console.log cmd
    $(@dom).parents(".collapse").find('.creating').collapse(cmd)