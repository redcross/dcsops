class window.AdminMapController
  constructor: (dom, @opts) ->
    mapOpts =
      center: new google.maps.LatLng(38, -120)
      zoom: 5
      mapTypeId: google.maps.MapTypeId.ROADMAP
      scrollwheel: false
    @map = new google.maps.Map(dom, mapOpts)

    if center = @opts['bind_center']
      lat = parseFloat($('#' + center['lat']).val()) || 38;
      lng = parseFloat($('#' + center['lng']).val()) || -121;

      l = new google.maps.LatLng(lat, lng)
      @map.setCenter l

    if zoom = @opts['bind_zoom']
      @map.setZoom (parseInt($('#' + zoom).val()) || 5)

    google.maps.event.addListener @map, 'zoom_changed', (evt) => @centerChanged()
    google.maps.event.addListener @map, 'center_changed', (evt) => @centerChanged()

  centerChanged: () ->
    if center = @opts['bind_center']
      $('#' + center['lat']).val(@map.getCenter().lat())
      $('#' + center['lng']).val(@map.getCenter().lng())

    if zoom = @opts['bind_zoom']
      $('#' + zoom).val(@map.getZoom())
