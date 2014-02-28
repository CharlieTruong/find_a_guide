
var Tour = function() {
this.template = $("<div class='tour_desc'>\
                    <div class='tour_text' contenteditable='true'></div>\
                    <br><button type='button' id='new_tour_button'>Save</button>\
                  </div>")
};

var styleOptions = [
                      {
                        "featureType": "poi",
                        "stylers": [
                          { "visibility": "off" }
                        ]
                      },{
                        "featureType": "poi.park",
                        "stylers": [
                          { "visibility": "on" }
                        ]
                      }
                    ]



var markers = [];

var marker_id = 0

$(document).ready(function() {
	var map;

  var mapOptions = {
    center: new google.maps.LatLng(20, 0),
    zoom: 2,
    streetViewControl: false,
    styles: styleOptions
  };

  var user_markers = [];
  var info_windows = [];

	function initialize() {
		map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
	
		google.maps.event.addListener(map, 'click', function(e) {
      $.each(info_windows, function(i,v) { info_windows[i].close(); });

			var myLatLng = new google.maps.LatLng(e.latLng['d'], e.latLng['e'])
      var user_marker = new google.maps.Marker({
        position: myLatLng,
        map: map
      })
      user_marker.set("id", marker_id++);
      var m_index = user_marker.get("id");
      user_markers.push(user_marker);
      
      var iw = new Tour()
    
      var infowindow = new google.maps.InfoWindow({content : iw.template[0] });
      $(infowindow.content).find('#new_tour_button').on('click', function() {
        var data = {
                    description: $($($(this).parent()[0]).find('.tour_text')[0]).html(),
                    latitude: user_marker.position['d'],
                    longitude: user_marker.position['e']
                   }

        $.post('/tours', data, function() {
          console.log('yea!')
        });



        // console.log($($($(this).parent()[0]).find('.tour_text')[0]).html());
        // console.log(user_marker.position['d'])
      });
      info_windows.push(infowindow)
      info_windows[m_index].open(map, user_markers[m_index]);

      
      $.each(user_markers, function(i, v) {
        google.maps.event.addListener(user_markers[i], 'click', function() {
          $.each(info_windows, function(i,v) { info_windows[i].close(); });
          info_windows[i].open(map, user_markers[i]);
        });
      });

    
      // $.each(user_markers, function(i, v) {
      //   bindInfoWindow(user_markers[i], map, info_windows[i], tour_description_template[0]);
      // });


      // function bindInfoWindow(marker, map, infowindow, html) {
      //   google.maps.event.addListener(marker, 'click', function() {
      //     // $.each(user_markers, function(i, v) {
      //     //   user_markers[i].infowindow.close();
      //     // });
      //     infowindow.setContent(html);
      //     infowindow.open(map, marker);

      //       // m_index = user_marker.get("id")
      //       // $.each(user_markers, function(i, v) {
      //       //   user_markers[i].infowindow.close();
      //       // });
      //       // user_markers[m_index].infowindow.open(map, user_markers[m_index]);
      //       // console.log(user_markers[m_index].infowindow)
      //   });
      // };
      



      // google.maps.event.addListener(user_marker, 'click', function() {
      //   infowindow.open(map, user_marker)
      // });


      // tour_description_template.find('#new_tour_button').on('click', function() {
      //   console.log(user_marker.position);
      //   var tour_data = { tour_desc : $('#tour_content').val(), coords : user_marker.position  }
        
      //   $.post('/tours', tour_data, function() {
      //     console.log('yea!')
      //   })
      // });

    
		});// end listener


  
		var input = (document.getElementById('pac-input'));
  	map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);

  	var searchBox = new google.maps.places.SearchBox(input);

    // Listen for the event fired when the user selects an item from the
    // pick list. Retrieve the matching places for that item.
  	google.maps.event.addListener(searchBox, 'places_changed', function() {
      var places = searchBox.getPlaces();

      for (var i = 0, marker; marker = markers[i]; i++) {
        marker.setMap(null);
      }

      // For each place, get the icon, place name, and location.
      var bounds = new google.maps.LatLngBounds();
      for (var i = 0, place; place = places[i]; i++) {
        var image = {
          url: place.icon,
          size: new google.maps.Size(71, 71),
          origin: new google.maps.Point(0, 0),
          anchor: new google.maps.Point(17, 34),
          scaledSize: new google.maps.Size(25, 25)
        };

        // Create a marker for each place.
        var marker = new google.maps.Marker({
          map: map,
          icon: image,
          title: place.name,
          position: place.geometry.location,
        });

        markers.push(marker);

        bounds.extend(place.geometry.location);
      }; //end for loop

      map.fitBounds(bounds);
      map.setZoom(15)
    }); //end searchBox event listener

    // Bias the SearchBox results towards places that are within the bounds of the
    // current map's viewport.
    google.maps.event.addListener(map, 'bounds_changed', function() {
      var bounds = map.getBounds();
      searchBox.setBounds(bounds);
    });
	}; //end initialize

	google.maps.event.addDomListener(window, 'load', initialize);

});