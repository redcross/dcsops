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

  constructor: (@currentLat, @currentLng, @config, @formBase='incidents_dat_incident_incident_attributes') ->
    @dom = $('.incident-map')[0]

    this.initGeocoder()

    unless this.maybeInitMap()
      id = $(@dom).closest('.tab-pane').attr('id')
      sel = "a[data-target=##{id}]"
      $(document).on 'shown.bs.tab', sel, (evt) =>
        this.maybeInitMap()

    @fields.forEach (fname) =>
      $(document).on 'change', "[id$=#{fname}]", (evt) =>
        this.updateMap()

    $(document).on 'click', 'button.address-lookup', (evt) =>
      evt.preventDefault();
      this.inputField('search_for_address').blur()

    $(document).on 'click', '.manual-address', (evt) =>
      #if confirm("Are you sure you want to ")
      this.allowDirectEntry()
      evt.preventDefault()

  maybeInitMap: () ->
    if ($(@dom).is(':visible'))
      this.initMap()
      true
    else
      false

  initMap: () ->
    return unless window.google # if no gmaps js, don't die
    return if @map?

    @map = MapFactory.createMap @dom, @config
    
    if @currentLng? and @currentLng?
      pos = new google.maps.LatLng(@currentLat, @currentLng)
      @map.setCenter pos
      @map.setZoom 12
      @marker.setPosition pos
      @marker.setMap @map

  initGeocoder: () ->
    return unless window.google
    @coder = new google.maps.Geocoder()
    @marker = new google.maps.Marker
    if @config.geocode_bounds?
      @bounds = new google.maps.LatLngBounds new google.maps.LatLng(@config.geocode_bounds[0], @config.geocode_bounds[1]), new google.maps.LatLng(@config.geocode_bounds[2], @config.geocode_bounds[3])

  inputField: (fname) ->
    $("[id$=incident_#{fname}],[id$=incident_attributes_#{fname}]")

  setFieldVal: (fname, val) ->
    this.inputField(fname).val(val)

  getFieldVal: (fname) ->
    this.inputField(fname).val()

  getAddressComponent: (result, type, key) ->
    val = null
    result.address_components.forEach (el) =>
      if el.types.indexOf(type) != -1
        val = el[key]
    return val

  filterCounty: (strOrNothing) ->
    if strOrNothing
      strOrNothing.replace(' County', '')
    else
      strOrNothing

  allowDirectEntry: () ->
    ['address', 'city', 'state', 'zip', 'county', 'neighborhood'].forEach (field) =>
      this.inputField(field).prop('editable', true).prop('readonly', false).prop('disabled', false)

  updateMap: () ->
    vals = @fields.map (fname) =>
      this.getFieldVal(fname)
    return unless vals[0]? and vals[0] != ''
    query = vals.join(", ")
    @coder.geocode {address:query, bounds: @bounds}, (results, status) =>
      ['address', 'lat', 'lng', 'neighborhood', 'city', 'state', 'zip', 'county'].forEach (field) =>
          this.setFieldVal field, ''
      if (status == google.maps.GeocoderStatus.OK)
        result = results[0]
        pos = result.geometry.location
        @currentLng = pos.lng()
        @currentLat = pos.lat()
        if @map
          @map.setCenter pos
          @map.setZoom 12
          @marker.setPosition(pos)
          @marker.setMap(@map)

        this.setFieldVal('address', result.formatted_address.split(", ")[0])
        this.setFieldVal('lat', pos.lat())
        this.setFieldVal('lng', pos.lng())

        city = null
        admin3 = null

        this.setFieldVal('state', this.getAddressComponent(result, 'administrative_area_level_1', 'short_name'))
        this.setFieldVal('county', this.filterCounty(this.getAddressComponent(result, 'administrative_area_level_2', 'long_name')))
        this.setFieldVal('zip', this.getAddressComponent(result, 'postal_code', 'long_name'))
        this.setFieldVal 'city', (this.getAddressComponent(result, 'sublocality', 'long_name') ||
                                  this.getAddressComponent(result, 'locality', 'long_name') ||
                                  this.getAddressComponent(result, 'administrative_area_level_3', 'long_name'))
        this.setFieldVal('neighborhood', this.getAddressComponent(result, 'neighborhood', 'long_name'))
      else
        @marker.setMap null

class window.AllIncidentsMapController

  constructor: (objects, config, autoFit) ->
    dom = $('.all-incidents-map')[0]
    @map = MapFactory.createMap dom, config,
      draggable: true
    @coder = new google.maps.Geocoder()
    @markers = objects.map (obj) =>
      new google.maps.Marker
        position: new google.maps.LatLng(obj.lat, obj.lng)
        map: @map

  configureBoundaryLayer: (tableId, filter) ->
    @boundaryLayer = new google.maps.FusionTablesLayer
      query:
        select: 'geometry'
        from: tableId
        where: "UNIT_CODE='#{filter}'"
      styles: [
        polygonOptions:
          fillColor: '#000000'
          fillOpacity: 0.00001
          strokeWeight: 3
      ]
    @boundaryLayer.setMap @map

class window.AllIncidentsHeatmapController

  constructor: (objects, display, config) ->
    @config = config

    dom = $('.all-incidents-map')[0]
    unless dom?
      return
    @map = MapFactory.createMap dom, config,
      draggable: true
      enableHover: false
      disableDefaultUI: false
    @coder = new google.maps.Geocoder()
    @bounds = new google.maps.LatLngBounds

    @validIcon =
      url: 'https://mts.googleapis.com/vt/icon/name=icons/spotlight/spotlight-waypoint-a.png&text=%20&psize=16&font=fonts/Roboto-Regular.ttf&color=ffff3333&ax=44&ay=48&scale=2'
      scaledSize: new google.maps.Size(17, 30)

    @invalidIcon =
      url: 'https://mts.googleapis.com/vt/icon/name=icons/spotlight/spotlight-waypoint-b.png&text=%20&psize=16&font=fonts/Roboto-Regular.ttf&color=ffff3333&ax=44&ay=48&scale=2'
      scaledSize: new google.maps.Size(17, 30)

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
        marker = new google.maps.Marker
          position: pt
          map: @map
          icon: this.iconForEvent(obj.status)
          title: obj.id
        google.maps.event.addListener marker,'click', (evt)=>(window.location = obj.url)
        marker

    @map.fitBounds @bounds

  iconForEvent: (event) ->
    if (event == 'invalid') then @invalidIcon else @validIcon

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

