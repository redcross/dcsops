class window.PartnerTypeaheadController
  canCreate: true
  createMessage: "Other/Not Listed"

  constructor: (dom, callback, filter={}) ->
    @callback = callback
    @dom = dom

    controller = this

    taOpts = 
      higlight: true

    mainDsOpts =
      name: "search"
      displayKey: "name"
      templates:
        suggestion: (datum) -> "<p>#{datum.name}<br />#{datum.address1}</p>"
      source: (query, process) =>
        if query.length <= 2
          process([])
          return

        $.ajax
          dataType: 'json'
          data:
            $.extend filter,
              q: 
                name_cont: query
          url: '/partners/partners'
          success: (data) =>
            @list = {}
            @prev_query = query
            @prev_data = data

            console.log data

            process(data)

    newDsOpts =
      name: "newPartner"
      displayKey: "name"
      templates:
        suggestion: (ctx) -> "<p>New Partner: #{ctx.name}</p>"
      source: (query, process) ->
        process([{isNew: true, value: query, name: query}])

    @dom.typeahead taOpts, mainDsOpts, newDsOpts
    
    $(@dom).on 'typeahead:selected', (evt, datum) =>
      console.log evt, evt.target, evt.target.value, datum
      if datum.id
        @callback(datum.id, datum)
        @setCreating false
      else
        @callback(null, null, datum.value)
        @setCreating true
      @selected = datum.full_name


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
    arr = serverData.slice()
    arr.push(name)
    process(arr)

  setCreating: (val) ->
    cmd = val && 'show' || 'hide'
    $(@dom).parents(".collapse").find('.creating').collapse(cmd)
    