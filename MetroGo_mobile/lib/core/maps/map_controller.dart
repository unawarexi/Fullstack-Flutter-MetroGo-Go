import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapController extends ChangeNotifier {
  late GoogleMapController _mapController;
  final Location _location = Location();
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  double panelPosition = 0.0;
  bool _isLocationInitialized = false;

  // Custom map style JSON
  static const String darkPurpleMapStyle = '''

[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#1d1d2c"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242435"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#a694d6"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59bf6"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9d7cd6"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263346"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8c64c9"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#332c4c"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#373357"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#4b3992"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#b485f8"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e86db"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#382e5c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#171730"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8575ce"
      }
    ]
  }
]
''';

  // Custom map style JSON for light theme
  static const String lightPurpleMapStyle = '''

[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f3f3f9"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b4ca5"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8e6cc7"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#7a5bb3"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e6e6f2"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b4ca5"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dcd6eb"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#d1c8e6"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#b39ddb"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b4ca5"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8e6cc7"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#d1c8e6"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e3e3f5"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b4ca5"
      }
    ]
  }
]
''';

  final CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194), // Default to San Francisco
    zoom: 14.0,
  );

  List<Map<String, String>> recentLocations = [
    {
      'name': 'Golden Gate Park',
      'address': 'San Francisco, CA',
      'timeAgo': '5 min ago',
    },
    {
      'name': 'Union Square',
      'address': 'San Francisco, CA',
      'timeAgo': '10 min ago',
    },
  ];

  void initializeMap() async {
    // Request location permissions
    final permissionGranted = await _location.requestPermission();
    if (permissionGranted == PermissionStatus.granted) {
      // Enable location services
      await _location.requestService();
    }
  }

  void onMapCreated(GoogleMapController controller, BuildContext context) {
    _mapController = controller;

    // Apply custom map style and handle errors
    _applyMapStyle(context);

    // Go to current location and add marker
    goToCurrentLocation();
  }

  void _applyMapStyle(BuildContext context) async {
    try {
      final isDarkMode = THelperFunctions.isDarkMode(context);
      final mapStyle = isDarkMode ? darkPurpleMapStyle : lightPurpleMapStyle;
      await _mapController.setMapStyle(mapStyle);
    } catch (e) {
      debugPrint('Error applying map style: $e');
    }
  }

  void onMapTapped(LatLng position) {
    // Add a marker at the tapped position
    markers.add(
      Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    );
    notifyListeners();
  }

  void goToCurrentLocation() async {
    final locationData = await _location.getLocation();
    final currentPosition = LatLng(
      locationData.latitude!,
      locationData.longitude!,
    );

    // Add current location marker if not already initialized
    if (!_isLocationInitialized) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
      _isLocationInitialized = true;
    }

    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(currentPosition, 15),
    );
    notifyListeners();
  }

  void updateRouteWithSearchResult(LatLng destination) {
    // Clear existing markers and polylines
    markers.clear();
    polylines.clear();
    _isLocationInitialized = false;

    // Get current location for route starting point
    _location.getLocation().then((locationData) {
      final currentPosition = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );

      // Add a marker for current location
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );

      // Add a marker for the destination
      markers.add(
        Marker(
          markerId: MarkerId(destination.toString()),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
      );

      // Add a polyline
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [currentPosition, destination],
          color: Colors.purple.shade300,
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );

      // Move camera to show both points
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              currentPosition.latitude < destination.latitude
                  ? currentPosition.latitude
                  : destination.latitude,
              currentPosition.longitude < destination.longitude
                  ? currentPosition.longitude
                  : destination.longitude,
            ),
            northeast: LatLng(
              currentPosition.latitude > destination.latitude
                  ? currentPosition.latitude
                  : destination.latitude,
              currentPosition.longitude > destination.longitude
                  ? currentPosition.longitude
                  : destination.longitude,
            ),
          ),
          100, // padding
        ),
      );

      notifyListeners();
    });
  }

  void selectSavedPlace(String place) {
    // Mocked saved place selection
    if (place == 'home') {
      updateRouteWithSearchResult(
        const LatLng(37.7749, -122.4194),
      ); // Example coordinates
    } else if (place == 'work') {
      updateRouteWithSearchResult(const LatLng(37.7849, -122.4094));
    }
  }

  void selectRecentLocation(int index) {
    // final location = recentLocations[index];
    // Mocked recent location selection
    updateRouteWithSearchResult(
      const LatLng(37.7649, -122.4294),
    ); // Example coordinates
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
