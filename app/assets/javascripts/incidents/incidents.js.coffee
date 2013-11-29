# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#class window.InvalidIncidentController
#  constructor: ->
#    $(document).on 'click', '#invalid-incident-button', (evt) =>
#      target = $(evt.target).data('invalid-url')
#      $('#invalid-incident').parents('form').attr('action', target)
#      $('#invalid-incident').modal('show')

class window.IncidentLocationController
  fields: ['search_for_address']
  form_base: 'incidents_dat_incident_incident_attributes'

  constructor: (currentLat, currentLng, config) ->
    return unless window.google # if no gmaps js, don't die

    @centerPoint = new google.maps.LatLng(config.lat, config.lng)

    dom = $('.incident-map')[0]
    google.maps.visualRefresh = true
    opts =
      zoom: config.zoom
      center: @centerPoint
      mapTypeId: google.maps.MapTypeId.ROADMAP
      scrollwheel: false
      draggable: false
      disableDefaultUI: true
    @map = new google.maps.Map(dom, opts)
    @coder = new google.maps.Geocoder()
    @marker = new google.maps.Marker
    @bounds = new google.maps.LatLngBounds new google.maps.LatLng(config.geocode_bounds[0], config.geocode_bounds[1]), new google.maps.LatLng(config.geocode_bounds[2], config.geocode_bounds[3])

    if currentLng? and currentLng?
      pos = new google.maps.LatLng(currentLat, currentLng)
      @map.setCenter pos
      @map.setZoom 12
      @marker.setPosition pos
      @marker.setMap @map

    @fields.forEach (fname) =>
      field = '#' + @form_base + '_' + fname
      $(document).on 'change', field, (evt) =>
        this.updateMap()

  setFieldVal: (fname, val) ->
    $('#' + @form_base + '_' + fname).val(val)

  getFieldVal: (fname) ->
    $('#' + @form_base + '_' + fname).val()

  updateMap: () ->
    vals = @fields.map (fname) =>
      this.getFieldVal(fname)
    return unless vals[0]? and vals[0] != ''
    query = vals.join(", ")
    @coder.geocode {address:query, bounds: @bounds}, (results, status) =>
      if (status == google.maps.GeocoderStatus.OK)
        result = results[0]
        pos = result.geometry.location
        @map.setCenter pos
        @map.setZoom 12
        @marker.setPosition(pos)
        @marker.setMap(@map)

        ['address', 'lat', 'lng', 'neighborhood', 'city', 'state', 'zip', 'county'].forEach (field) =>
          this.setFieldVal field, ''

        this.setFieldVal('address', result.formatted_address.split(", ")[0])
        this.setFieldVal('lat', pos.lat())
        this.setFieldVal('lng', pos.lng())

        result.address_components.forEach (el) =>
          el.types.forEach (type) =>
            if type == 'neighborhood'
              this.setFieldVal('neighborhood', el.long_name)
            else if type == 'locality'
              this.setFieldVal('city', el.long_name)
            else if type == 'administrative_area_level_1'
              this.setFieldVal('state', el.short_name)
            else if type == 'administrative_area_level_2'
              this.setFieldVal('county', el.short_name)
            else if type == 'postal_code'
              this.setFieldVal('zip', el.long_name)
      else
        @marker.setMap null

class window.AllIncidentsMapController

  constructor: (objects, config) ->
    dom = $('.all-incidents-map')[0]
    google.maps.visualRefresh = true
    opts =
      zoom: config.zoom
      center: new google.maps.LatLng(config.lat, config.lng)
      mapTypeId: google.maps.MapTypeId.ROADMAP
      scrollwheel: false
      draggable: true
      disableDefaultUI: true
    @map = new google.maps.Map(dom, opts)
    @coder = new google.maps.Geocoder()
    @markers = objects.map (obj) =>
      new google.maps.Marker
        position: new google.maps.LatLng(obj.lat, obj.lng)
        map: @map

class window.AllIncidentsHeatmapController

  constructor: (objects, display, config) ->
    @config = config

    dom = $('.all-incidents-map')[0]
    google.maps.visualRefresh = true
    opts =
      zoom: 9
      center: new google.maps.LatLng(37.81871654, -122.19014746)
      mapTypeId: google.maps.MapTypeId.ROADMAP
      scrollwheel: false
      draggable: true
      disableDefaultUI: true
    @map = new google.maps.Map(dom, opts)
    @coder = new google.maps.Geocoder()
    @bounds = new google.maps.LatLngBounds

    if display == 'heatmap'
      @data = objects.map (obj) =>
        pt = new google.maps.LatLng(obj.lat, obj.lng)
        @bounds.extend  pt
        location: pt
        #weight: obj.clients
        
      @heatmap = new google.maps.visualization.HeatmapLayer
        data: @data
      @heatmap.setMap @map
    else
      @markers = objects.map (obj) =>
        pt = new google.maps.LatLng(obj.lat, obj.lng)
        @bounds.extend pt
        new google.maps.Marker
          position: pt
          map: @map
          icon: this.iconForEvent(obj.status)

    @map.fitBounds @bounds

  iconForEvent: (event) ->
    ""

class window.IncidentsTrackerController
  constructor: () ->
    $(".narrative-button").on "click", (evt) =>
      el = $(evt.target)
      path = el.data('url')
      $("#narrative-modal .modal-body").text('Loading...')
      $("#narrative-modal").modal('show')
      $.ajax
        url: path
        success: (data, status, xhr) =>
          $("#narrative-modal .modal-body").html(data)
          setTimeout ( () -> $("#narrative-modal .modal-body").scrollTop(0) ), 100

class window.IncidentEventLogsController
  constructor: () ->
    $('#add-log-button').on "click", (evt) =>
      $("#create-event-modal").modal('show')

class window.IncidentEditPanelController
  updateMapping:
    demographics: 'details'
    damage_assessment: 'details'
    location: 'details'

  constructor: (edit_url) ->
    $(document).on 'click', '[data-toggle=tab]', (evt) =>
      console.log 'got click!'
      evt.preventDefault()
      evt.stopPropagation()
      false

    $(document).on 'click', '[data-edit-panel]', (evt) =>
      evt.preventDefault()

      panel = $(evt.target).data('edit-panel')
      modal = $('#edit-modal')

      modal.modal('show')
      modal.html('<div class="modal-body">Loading</div>')
      $.ajax
        url: edit_url
        data: {panel_name: panel}
        success: (data, status, xhr) =>
          modal.html(data)
          modal.find('legend').remove()

    $(document).on 'edit-panel:success', (evt, panel) =>
      console.log(panel);
      $('#edit-modal').modal('hide');

      this.updateTab(@updateMapping[panel])


  updateTab: (tabName) ->
    tabName = 'details'
    return unless tabName
    $.ajax
      url: window.location.href
      data:
        partial: tabName
      success: (data, status, xhr) =>
        $("#inc-#{tabName}").html(data)