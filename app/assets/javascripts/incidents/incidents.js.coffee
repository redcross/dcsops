# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class window.IncidentLocationController
  fields: ['address', 'city', 'state', 'zip']

  constructor: (currentLat, currentLng) ->
    dom = $('.incident-map')[0]
    google.maps.visualRefresh = true
    opts =
      zoom: 9
      center: new google.maps.LatLng(37.81871654, -122.19014746)
      mapTypeId: google.maps.MapTypeId.ROADMAP
      scrollwheel: false
      draggable: false
      disableDefaultUI: true
    @map = new google.maps.Map(dom, opts)
    @coder = new google.maps.Geocoder()
    @marker = new google.maps.Marker
    @bounds = new google.maps.LatLngBounds new google.maps.LatLng(36.5407938301337, -124.57967382718749), new google.maps.LatLng(39.143091210253154, -119.52596288968749)

    if currentLng? and currentLng?
      pos = new google.maps.LatLng(currentLat, currentLng)
      @map.setCenter pos
      @map.setZoom 12
      @marker.setPosition pos
      @marker.setMap @map

    @fields.forEach (fname) =>
      $('#incidents_incident_' + fname).on 'change', (evt) =>
        this.updateMap()

  updateMap: () ->
    vals = @fields.map (fname) ->
      $('#incidents_incident_' + fname).val()
    return unless vals[0]? and vals[0] != '' and vals[1]? and vals[1] != ''
    query = vals.join(", ")
    console.log query
    @coder.geocode {address:query, location: @map.getCenter(), bounds: @bounds}, (results, status) =>
      if (status == google.maps.GeocoderStatus.OK)
        result = results[0]
        console.log result
        pos = result.geometry.location
        @map.setCenter pos
        @map.setZoom 12
        @marker.setPosition(pos)
        @marker.setMap(@map)

        $('#incidents_incident_lat').val(pos.lat())
        $('#incidents_incident_lng').val(pos.lng())
      else
        console.log status, results
        @marker.setMap null

class window.AllIncidentsMapController

  constructor: (objects) ->
    dom = $('.all-incidents-map')[0]
    console.log dom
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
    @markers = objects.map (obj) =>
      new google.maps.Marker
        position: new google.maps.LatLng(obj.lat, obj.lng)
        map: @map

class window.AllIncidentsHeatmapController

  constructor: (objects, display) ->
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

    @map.fitBounds @bounds

