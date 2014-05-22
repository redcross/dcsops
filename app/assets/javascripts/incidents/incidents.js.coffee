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
      $(document).on 'shown', sel, (evt) =>
        this.maybeInitMap()

    @fields.forEach (fname) =>
      $(document).on 'change', "[id$=#{fname}]", (evt) =>
        this.updateMap()

    $(document).on 'click', 'button.address-lookup', (evt) =>
      evt.preventDefault();
      this.inputField('search_for_address').blur()

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

  constructor: (objects, config) ->
    dom = $('.all-incidents-map')[0]
    @map = MapFactory.createMap dom, config,
      draggable: true
    @coder = new google.maps.Geocoder()
    @markers = objects.map (obj) =>
      new google.maps.Marker
        position: new google.maps.LatLng(obj.lat, obj.lng)
        map: @map

class window.AllIncidentsHeatmapController

  constructor: (objects, display, config) ->
    @config = config

    dom = $('.all-incidents-map')[0]
    @map = MapFactory.createMap dom, config,
      draggable: true
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
        marker = new google.maps.Marker
          position: pt
          map: @map
          icon: this.iconForEvent(obj.status)
        google.maps.event.addListener marker,'click', ()=>(console.log obj.id)
        marker

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

class window.IncidentEditPanelController
  updateMapping:
    demographics: 'details'
    damage_assessment: 'details'
    location: 'details'

  constructor: () ->
    $(document).on 'click', '[data-toggle=tab]', (evt) =>
      evt.preventDefault()
      evt.stopPropagation()
      false

    $(document).on 'click', '[data-edit-panel]', (evt) =>
      evt.preventDefault()

      panel = $(evt.target).data('edit-panel')
      modal = $('#edit-modal')

      modal.modal({show: true, keyboard: false})
      modal.html('<div class="modal-body">Loading</div>')
      $.ajax
        url: panel
        dataType: 'html'
        success: (data, status, xhr) ->
          modal.html(data)
          modal.find('legend').remove()
        error: (xhr, status, error) ->
          wrapper = $('<div class="modal-body text-error">An error occurred: <span class="error-value"></span>.  Please try again.<a class="close" data-dismiss="modal">&times;</a></div>')
          wrapper.find(".error-value").text(error)
          modal.html("")
          modal.append(wrapper)

    $(document).on 'edit-panel:success', (evt, panels) =>
      console.log(panels);
      panels = [].concat(panels);
      $('#edit-modal').modal('hide');

      panels.forEach (panel) =>
        this.updateTab(panel)
      if $('#inc-changes').length > 0
        this.updateTab('changes')


  updateTab: (tabName) ->
    #tabName = 'details'
    return unless tabName
    return unless $("#inc-#{tabName}").length > 0
    $.ajax
      url: window.location.href
      data:
        partial: tabName
      success: (data, status, xhr) =>
        $("#inc-#{tabName}").html(data)
