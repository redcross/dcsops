window.MapFactory =
  defaultOptions: (mapConfig) ->
    styles: this.stylers
    center: new google.maps.LatLng(mapConfig.lat, mapConfig.lng)
    zoom: mapConfig.zoom
    mapTypeId: google.maps.MapTypeId.ROADMAP
    scrollwheel: false
    draggable: false
    disableDefaultUI: true
    styles: this.stylers
    enableHover: true

  stylers: [
      {
        featureType: "poi",
        elementType: "labels",
        stylers: [{ visibility: "off" }]
      }
    ]

  controlsIn:
    disableDefaultUI: false
    draggable: true
    #zoomControl: true
    #panControl: true

  controlsOut:
    disableDefaultUI: true
    draggable: false
    #zoomControl: false
    #panControl: false

  createMap: (dom, mapConfig, options) ->
    return null unless window.google
    google.maps.visualRefresh = true
    
    mapOpts = $.extend({}, this.defaultOptions(mapConfig), options)

    map = new google.maps.Map(dom, mapOpts)

    if mapOpts.enableHover
      this.setupHover(map, dom)

    return map

  setupHover: (map, dom) ->

    $(dom).mouseenter (evt) =>
      if (!map.hover)
        map.hover = true
        map.setOptions this.controlsIn

    $('body').mouseover (evt) =>
      if (map.hover)
        if $(evt.target).closest(dom).length == 0
          map.hover = false
          map.setOptions this.controlsOut

window.MapHelper =
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

  getCity: (result) ->
    MapHelper.getAddressComponent(result, 'sublocality', 'long_name') || MapHelper.getAddressComponent(result, 'locality', 'long_name') || MapHelper.getAddressComponent(result, 'administrative_area_level_3', 'long_name')


