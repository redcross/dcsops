class window.IncidentRespondersController

  constructor: () ->

  initMap: (config, dom) ->
    @map = MapFactory.createMap(dom, config)
    return unless @map? # If loading the maps library failed somehow
    @coder = new google.maps.Geocoder()
    @incidentMarker = new google.maps.Marker

    if config.geocode_bounds?
      @bounds = new google.maps.LatLngBounds new google.maps.LatLng(config.geocode_bounds[0], config.geocode_bounds[1]), new google.maps.LatLng(config.geocode_bounds[2], config.geocode_bounds[3])
      @map.fitBounds @bounds

    @responderIcon =
      url: 'https://mts.googleapis.com/vt/icon/name=icons/spotlight/spotlight-waypoint-a.png&text=%20&psize=16&font=fonts/Roboto-Regular.ttf&color=ffff3333&ax=44&ay=48&scale=2'
      scaledSize: new google.maps.Size(17, 30),

  setIncidentLocation: (lat, lng) ->
    return unless @map? and lat? and lng? and lat != 0 and lng != 0
    @incidentLocation = new google.maps.LatLng(lat, lng)
    @incidentMarker.setPosition @incidentLocation
    @incidentMarker.setMap @map

  loadTravelTimes: () ->
    return unless @incidentLocation?

    @distanceService ||= new google.maps.DistanceMatrixService()

    elements = $('[data-person]:not([data-travel-lookup])').slice(0, 25)

    return unless elements.length > 0

    people = elements.map((idx, el) -> $(el).data('person'))

    origins = people.map((idx, el) -> new google.maps.LatLng(parseFloat(el.lat), parseFloat(el.lng)))

    @distanceService.getDistanceMatrix
      origins: origins
      destinations: [@incidentLocation]
      travelMode: google.maps.TravelMode.DRIVING
      unitSystem: google.maps.UnitSystem.IMPERIAL
      durationInTraffic: true
      (resp, status) => 
        if status != "OK"
          console.log resp, status
          return

        resp.rows.forEach (row, idx) =>
          result = row['elements'][0]
          this.processTravelTime(elements[idx], result)
        this.loadTravelTimes()
        this.sortTables()

  travelTimeClass: (element, time) ->
    mins = time/60
    $(element).toggleClass('travel-short', mins < 30 )
    $(element).toggleClass('travel-medium', mins >= 30 and mins < 90)
    $(element).toggleClass('travel-long', mins >= 90)

  processTravelTime: (element, result) ->
    # Put this before checking result quality to ensure we don't
    # continually retry addresses where google doesn't return something
    $(element).attr('data-travel-lookup', true)

    return unless result? and result['status'] == 'OK'

    if result['duration_in_traffic']
      $('img.traffic-icon').css('display', 'inline')
    duration = result['duration_in_traffic'] || result['duration']

    $(element).find('.distance').text(result['distance']['text'])
    $(element).find('.travel-time').text(duration['text'])
    $(element).data('travel', result)
    this.travelTimeClass(element, duration['value'])

  sortTables: () ->
    travelTime = (el) ->
      result = $(el).data('travel')
      return Infinity unless result?
      duration = result['duration_in_traffic'] || result['duration']
      duration['value']

    $('tbody.responders-list.sort').each (idx, body) =>
      $(body).find('> tr').sortElements (a, b) =>
        travelTime(a) - travelTime(b)


  mapResponders: () ->
    return unless @map?
    elements = $('[data-person]')

    extent = new google.maps.LatLngBounds
    extent.extend @incidentLocation

    elements.map (idx, el) =>
      data = $(el).data('person')
      return unless data.lat? and data.lng?
      pos = new google.maps.LatLng parseFloat(data.lat), parseFloat(data.lng)
      marker = new google.maps.Marker
        position: pos
        map: @map
        icon: @responderIcon
        title: data.full_name
      extent.extend pos

    @map.fitBounds extent

class window.IncidentAssignmentController
  constructor: (@mapConfig, @mapDom, directionsDom) ->

    config = @mapConfig
    dom = @mapDom

    @map = MapFactory.createMap(dom, @mapConfig)
    return unless @map?
    @coder = new google.maps.Geocoder()
    @incidentMarker = new google.maps.Marker
    @bounds = new google.maps.LatLngBounds new google.maps.LatLng(config.geocode_bounds[0], config.geocode_bounds[1]), new google.maps.LatLng(config.geocode_bounds[2], config.geocode_bounds[3])

    @directionsService = new google.maps.DirectionsService
    @renderer = new google.maps.DirectionsRenderer
    @renderer.setMap @map
    @renderer.setPanel directionsDom

    trafficLayer = new google.maps.TrafficLayer();
    trafficLayer.setMap(@map);

  showAssignment: (incLat, incLng, personLat, personLng) ->
    @incidentLocation = new google.maps.LatLng incLat, incLng
    personLocation = new google.maps.LatLng personLat, personLng

    @directionsService.route 
      origin: personLocation
      destination: @incidentLocation
      travelMode: google.maps.TravelMode.DRIVING
      unitSystem: google.maps.UnitSystem.IMPERIAL
      durationInTraffic: true
      (resp, status) =>
        if status == google.maps.DirectionsStatus.OK
          @renderer.setDirections resp
          distance = try
            resp.routes[0].legs[0].distance.value
          catch
            null
          if distance
            this.setDistanceMeters(distance)

  setDistanceMeters: (distance) ->
    distance = distance / 1609.3
    $('input[id$=driving_distance]').val(distance)




