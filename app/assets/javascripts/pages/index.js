!function() {

  var map,
      kmlLayer,
      jsonCluster,
      jsonMarkers = [];

  function init() {
    $("input.map-toggle").bootstrapSwitch();
    $("input.map-toggle").on('switchChange.bootstrapSwitch', function(event, state) {
      if (state) {
        showJson();
        hideKml();
      } else {
        hideJson();
        showKml();
      }
    });

    var callback;
    if ($("input.map-toggle").bootstrapSwitch('state')) {
      callback = showJson;
    } else {
      callback = showKml;
    }

    initMap();
    initKml(function(){
      initJson(callback);
    });
  };

  function initMap() {
    var sanFrancisco = new google.maps.LatLng(37.7833, -122.4167);
    var mapOptions = {
      zoom: 12,
      center: sanFrancisco
    };
    map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
  };

  function initKml(callback) {
    kmlLayer = new google.maps.KmlLayer({ url: window.kmlUrl });
    callback();
  };

  function initJson(callback) {
    $.getJSON( window.jsonUrl, function( data ) {
      $.each( data, function( key, val ) {
        var latLng = new google.maps.LatLng(val.latitude, val.longitude);
        var marker = new google.maps.Marker({'position': latLng});
        jsonMarkers.push(marker);
      });

      jsonCluster = new MarkerClusterer(map, []);
      callback();
    });
  };

  function hideKml() {
    kmlLayer.setMap(null);
  };

  function showKml() {
    kmlLayer.setMap(map);
  };

  function hideJson() {
    jsonCluster.clearMarkers();
  };

  function showJson() {
    jsonCluster.addMarkers(jsonMarkers);
  };

  $(document).ready(init);

}();
