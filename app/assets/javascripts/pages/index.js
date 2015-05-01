!function() {

  var map,
      kmlLayer,
      jsonCluster,
      jsonInfoWindow,
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

        var fn = markerClick(createInfoWindowContent(val), latLng);
        google.maps.event.addListener(marker, 'click', fn);
        jsonMarkers.push(marker);
      });

      jsonInfoWindow = new google.maps.InfoWindow();
      jsonCluster = new MarkerClusterer(map, []);
      callback();
    });
  };

  function createInfoWindowContent(data) {
    var content = "<div class='info-window-content'><h4>" + data.permit_number + " (" + data.permit_type + ")</h4>"; 
      
      content += "<p><strong>Agent:</strong> " + data.agent + " (<a href='tel:" + 
                  data.agentphone + "'>" + formatPhone(data.agentphone) + "</a>)</p>";

    if (  data.agentphone != data.contactphone &&
          data.contactphone != null &&
          data.contact.toLowerCase() != 'refer to agent' ) {
      content += "<p><strong>Contact:</strong> <a href='tel:" + 
                 data.contactphone + "'>" + data.contact + "</a></p>";
    }

    content +=  "<p><strong>Purpose:</strong> " + data.permit_purpose + "</p></div>";
    return content;
  };

  function markerClick(content, latlng) {
    return function(e) {
      e.cancelBubble = true;
      e.returnValue = false;
      if (e.stopPropagation) {
        e.stopPropagation();
        e.preventDefault();
      }

      jsonInfoWindow.setContent(content);
      jsonInfoWindow.setPosition(latlng);
      jsonInfoWindow.open(map);
    };
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

  function formatPhone(phone) {
    text = phone.replace(/\+1(\d{3})(\d{3})(\d{4})/, "$1-$2-$3");
    return text;
  };

  $(document).ready(init);

}();
