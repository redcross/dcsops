class window.IncidentRespondersController

  constructor: () ->
    $(document).on 'click', '[data-assign]', (evt) =>
      return true
      evt.preventDefault()
      person_id = $(evt.target).data('assign')

      $modal = $('#edit-modal')

      $modal.text('Loading').modal('show')
      $.ajax
        url: window.location.href + '/new'
        data:
          person_id: person_id
        success: (data, status, xhr) =>
          $modal.html(data)

    $(document).on 'edit-panel:success', (evt, person) =>
      console.log(person);
      $('#edit-modal').modal('hide');
      $("tr[data-person-id=#{person}]").remove()

  initMap: (config, dom) ->
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
    @incidentMarker = new google.maps.Marker
    @bounds = new google.maps.LatLngBounds new google.maps.LatLng(config.geocode_bounds[0], config.geocode_bounds[1]), new google.maps.LatLng(config.geocode_bounds[2], config.geocode_bounds[3])

    @map.fitBounds @bounds

  setIncidentLocation: (lat, lng) ->
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
          if result['status'] == 'OK'
            this.processTravelTime(elements[idx], result)
        this.loadTravelTimes()

  travelTimeClass: (element, time) ->
    mins = time/60
    $(element).toggleClass('travel-short', mins < 30 )
    $(element).toggleClass('travel-medium', mins >= 30 and mins < 90)
    $(element).toggleClass('travel-long', mins >= 90)

  processTravelTime: (element, result) ->
    $(element).find('.distance').text(result['distance']['text'])
    $(element).find('.travel-time').text(result['duration']['text'])
    $(element).data('travel', result).attr('data-travel-lookup', true)
    this.travelTimeClass(element, result['duration']['value'])


  mapResponders: () ->
    elements = $('[data-person]')

    extent = new google.maps.LatLngBounds
    extent.extend @incidentLocation

    elements.map (idx, el) =>
      data = $(el).data('person')
      pos = new google.maps.LatLng parseFloat(data.lat), parseFloat(data.lng)
      marker = new google.maps.Marker
      marker.setPosition pos
      marker.setMap @map
      extent.extend pos

    @map.fitBounds extent

class window.IncidentAssignmentController
  constructor: (@mapConfig, @mapDom, directionsDom) ->

    config = @mapConfig
    dom = @mapDom

    google.maps.visualRefresh = true
    opts =
      zoom: config.zoom
      center: @centerPoint
      mapTypeId: google.maps.MapTypeId.ROADMAP
      scrollwheel: false
      draggable: true
      disableDefaultUI: false
    @map = new google.maps.Map(dom, opts)
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
        console.log resp, status
        if status == google.maps.DirectionsStatus.OK
          @renderer.setDirections resp




