import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart'
    as flutter_places_prediction;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_webservice2/places.dart' as webservice_places;
import 'package:google_maps_webservice2/directions.dart'
    as webservice_directions;

class LocationService {
  // Constants
  final String googleApiKey = "AIzaSyBoWy2-vzkQzOw9FrCKUyfxWpa5_dsPi10";

  // Controllers
  GoogleMapController? mapController;
  StreamController<Position> locationStreamController =
      StreamController<Position>.broadcast();

  // Map-related variables
  final Map<String, Marker> _markers = {};
  final Map<String, Polyline> _polylines = {};
  final Set<Circle> _geofenceCircles = {};

  // Current location variables
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  // Offline map variables
  Map<String, dynamic> _offlineMapData = {};
  final bool _isOfflineMode = false;

  // WebSocket for real-time tracking
  WebSocketChannel? _trackingChannel;

  // Singleton pattern
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  //-------------------------------- Check and request permissions
  Future<void> _checkAndRequestPermissions() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    //----------------------------------- Check for location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
  }

  //------------------------------- Initialize the location service
  Future<void> initialize() async {
    await _checkAndRequestPermissions();
    await _setupLocationStream();
  }

  //----------------------------------- Define the _setupLocationStream method
  Future<void> _setupLocationStream() async {
    try {
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update if moved 10 meters
        ),
      ).listen((Position position) {
        _currentPosition = position;
        locationStreamController.add(position);
      });
    } catch (e) {
      print('Error setting up location stream: $e');
    }
  }

  //---------------------------------------- Clean up resources
  void dispose() {
    _positionStreamSubscription?.cancel();
    locationStreamController.close();
    mapController?.dispose();
    _trackingChannel?.sink.close();
  }

  //--------------------------------------------- STEP 1: GET USER LOCATION FROM DEVICE
  Future<Position> getUserLocation() async {
    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      // Check for permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }

      // Get current position with high accuracy
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      // Update the stream with the new position
      locationStreamController.add(_currentPosition!);

      return _currentPosition!;
    } catch (e) {
      print('Error getting location: $e');

      // Try fallback to last known position if current fails
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          _currentPosition = lastPosition;
          locationStreamController.add(lastPosition);
          return lastPosition;
        }
      } catch (e) {
        print('Error getting last known location: $e');
      }

      rethrow;
    }
  }

  //---------------------------------------------------- STEP 2: DISPLAY MAP WITH USER LOCATION
  Widget buildMap({
    double zoom = 14.0,
    bool showTraffic = false,
    MapType mapType = MapType.normal,
    bool myLocationEnabled = true,
    bool myLocationButtonEnabled = true,
    void Function(GoogleMapController)? onMapCreated,
  }) {
    // Default to a position if we don't have one yet
    final initialPosition =
        _currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : LatLng(
              0,
              0,
            ); // Default position will be updated once we get location

    return StreamBuilder<Position>(
      stream: locationStreamController.stream,
      builder: (context, snapshot) {
        // If we have a position from the stream, use it
        final position =
            snapshot.hasData
                ? LatLng(snapshot.data!.latitude, snapshot.data!.longitude)
                : initialPosition;

        return GoogleMap(
          initialCameraPosition: CameraPosition(target: position, zoom: zoom),
          markers: Set<Marker>.of(_markers.values),
          polylines: Set<Polyline>.of(_polylines.values),
          circles: _geofenceCircles,
          mapType: mapType,
          myLocationEnabled: myLocationEnabled,
          myLocationButtonEnabled: myLocationButtonEnabled,
          trafficEnabled: showTraffic,
          zoomControlsEnabled: true,
          compassEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;

            // Apply map style if needed
            if (_isDarkMode(context)) {
              _setDarkMapStyle(controller);
            }

            // If we don't have a position yet, get one and move the camera
            if (_currentPosition == null) {
              getUserLocation().then((position) {
                _animateToPosition(
                  LatLng(position.latitude, position.longitude),
                );
              });
            }

            // Call the provided callback if available
            if (onMapCreated != null) {
              onMapCreated(controller);
            }
          },
        );
      },
    );
  }

  // Animate camera to a specific position
  Future<void> _animateToPosition(LatLng position) async {
    if (mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 15),
        ),
      );
    }
  }

  // Animate camera to a specific position
  // Future<void> animateToPosition(LatLng position, {double zoom = 15.0}) async {
  //   if (mapController != null) {
  //     await mapController!.animateCamera(
  //       CameraUpdate.newCameraPosition(
  //         CameraPosition(target: position, zoom: zoom),
  //       ),
  //     );
  //   }
  // }

  //---------------------------------------------------- STEP 5: IMPLEMENT SEARCH FOR DESTINATIONS
  Future<flutter_places_prediction.Prediction?> searchPlaces(
    BuildContext context,
    dynamic PlacesAutocomplete,
  ) async {
    try {
      flutter_places_prediction.Prediction? prediction =
          await PlacesAutocomplete.show(
            context: context,
            apiKey: googleApiKey,
            mode: AutocompleteMode.overlay, // Corrected usage
            language: "en",
            types: [],
            strictbounds: false,
            components: [
              webservice_places.Component(
                webservice_places.Component.country,
                "us",
              ),
            ], // Customize for your region
            decoration: InputDecoration(
              hintText: "Search for a destination",
              filled: true,
              fillColor: Colors.white,
            ),
          );

      return prediction;
    } catch (e) {
      print('Error searching places: $e');
      return null;
    }
  }

  // Get LatLng from place prediction
  Future<LatLng?> getLatLngFromPrediction(
    flutter_places_prediction.Prediction prediction,
  ) async {
    try {
      final response = await Dio().get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': prediction.placeId,
          'fields': 'geometry',
          'key': googleApiKey,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final lat = response.data['result']['geometry']['location']['lat'];
        final lng = response.data['result']['geometry']['location']['lng'];
        return LatLng(lat, lng);
      }
      return null;
    } catch (e) {
      print('Error getting location from prediction: $e');
      return null;
    }
  }

  //----------------------------------------------------------- STEP 6: ADD POLYLINES FOR ROUTES
  Future<void> addPolyline({
    required LatLng origin,
    required LatLng destination,
    List<LatLng> waypoints = const [],
    String polylineId = 'route',
    Color color = Colors.blue,
    int width = 5,
    String travelMode = 'driving',
  }) async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> points = [];

      // If there are waypoints, we need to handle them differently
      if (waypoints.isNotEmpty) {
        // For multiple waypoints, we'll use the directions API directly
        final routePoints = await _getRouteWithWaypoints(
          origin: origin,
          destination: destination,
          waypoints: waypoints,
          travelMode: travelMode,
        );
        points = routePoints;
      } else {
        // Simple route between two points
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          request: PolylineRequest(
            origin: PointLatLng(origin.latitude, origin.longitude),
            destination: PointLatLng(destination.latitude, destination.longitude),
            travelMode: TravelMode.driving, // Adjust travel mode as needed
            apiKey: googleApiKey,
          ),
        );

        if (result.points.isNotEmpty) {
          points = result.points;
        }
      }

      // Create a list of LatLng from the points
      List<LatLng> polylineCoordinates =
          points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

      // Create the polyline
      final Polyline polyline = Polyline(
        polylineId: PolylineId(polylineId),
        color: color,
        points: polylineCoordinates,
        width: width,
      );

      // Add to our collection
      _polylines[polylineId] = polyline;
    } catch (e) {
      print('Error adding polyline: $e');
    }
  }

  //------------------------------------------------ Helper method to get travel mode
  TravelMode _getTravelMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'walking':
        return TravelMode.walking;
      case 'bicycling':
        return TravelMode.bicycling;
      case 'transit':
        return TravelMode.transit;
      case 'driving':
      default:
        return TravelMode.driving;
    }
  }

  //-------------------------------------------------------------------- STEP 7: ADD DIRECTIONS TO THE MAP
  Future<Map<String, dynamic>> getDirections({
    required LatLng origin,
    required LatLng destination,
    List<LatLng> waypoints = const [],
    String travelMode = 'driving',
  }) async {
    try {
      // Build waypoints string if needed
      String waypointsStr = '';
      if (waypoints.isNotEmpty) {
        waypointsStr = waypoints
            .map((point) => 'via:${point.latitude},${point.longitude}')
            .join('|');
      }

      // Make request to Directions API
      var response = await Dio().get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          if (waypointsStr.isNotEmpty) 'waypoints': waypointsStr,
          'mode': travelMode,
          'key': googleApiKey,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        // Extract useful information
        final route = response.data['routes'][0];
        final leg = route['legs'][0];

        // Parse the results
        Map<String, dynamic> directionInfo = {
          'distance': leg['distance']['text'],
          'distanceValue': leg['distance']['value'], // in meters
          'duration': leg['duration']['text'],
          'durationValue': leg['duration']['value'], // in seconds
          'startAddress': leg['start_address'],
          'endAddress': leg['end_address'],
          'steps': leg['steps'],
          'overviewPolyline': route['overview_polyline']['points'],
        };

        // If there's traffic, add ETA with traffic
        if (response.data['routes'][0]['legs'][0]['duration_in_traffic'] !=
            null) {
          directionInfo['durationInTraffic'] =
              leg['duration_in_traffic']['text'];
          directionInfo['durationInTrafficValue'] =
              leg['duration_in_traffic']['value'];
        }

        // Cache the route for offline use
        _cacheRouteData(directionInfo);

        return directionInfo;
      } else {
        throw Exception('Failed to get directions: ${response.data['status']}');
      }
    } catch (e) {
      print('Error getting directions: $e');

      // If we're offline, try to get cached route
      if (_isOfflineMode && _offlineMapData.containsKey('routes')) {
        return _offlineMapData['routes'];
      }

      rethrow;
    }
  }

  //-------------------------------------------------- Helper method to get route with waypoints
  Future<List<PointLatLng>> _getRouteWithWaypoints({
    required LatLng origin,
    required LatLng destination,
    required List<LatLng> waypoints,
    required String travelMode,
  }) async {
    try {
      // Build waypoints string
      String waypointsStr = waypoints
          .map((point) => 'via:${point.latitude},${point.longitude}')
          .join('|');

      // Make request to Directions API
      var response = await Dio().get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'waypoints': waypointsStr,
          'mode': travelMode,
          'key': googleApiKey,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        // Get the encoded polyline
        String encodedPolyline =
            response.data['routes'][0]['overview_polyline']['points'];

        // Decode the polyline
        PolylinePoints polylinePoints = PolylinePoints();
        List<PointLatLng> decodedPolyline = polylinePoints.decodePolyline(
          encodedPolyline,
        );

        return decodedPolyline;
      } else {
        throw Exception(
          'Failed to get route with waypoints: ${response.data['status']}',
        );
      }
    } catch (e) {
      print('Error getting route with waypoints: $e');
      return [];
    }
  }

  //------------------------------------------------------------------- STEP 8: ADD MARKERS FOR PICKUP AND DROP-OFFS
  void addMarker({
    required String markerId,
    required LatLng position,
    String title = '',
    String snippet = '',
    BitmapDescriptor icon = BitmapDescriptor.defaultMarker,
    VoidCallback? onTap,
  }) {
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(title: title, snippet: snippet),
      icon: icon,
      onTap: onTap,
    );

    _markers[markerId] = marker;
  }

  // Remove a marker by ID
  void removeMarker(String markerId) {
    _markers.remove(markerId);
  }

  // Clear all markers
  void clearMarkers() {
    _markers.clear();
  }

  //--------------------------------------------------------------- STEP 8: CALCULATE DISTANCE AND PRICE BASED ON TRANSPORT MODE
  Future<Map<String, dynamic>> calculateRouteDetails({
    required LatLng origin,
    required LatLng destination,
    String travelMode = 'driving',
    double pricePerKm = 1.5, // Default price per km
    double baseFare = 2.0, // Base fare
  }) async {
    try {
      // Get directions first
      Map<String, dynamic> directions = await getDirections(
        origin: origin,
        destination: destination,
        travelMode: travelMode,
      );

      // Calculate distance in kilometers
      double distanceInMeters = directions['distanceValue'].toDouble();
      double distanceInKm = distanceInMeters / 1000;

      // Calculate duration in minutes
      double durationInSeconds = directions['durationValue'].toDouble();
      double durationInMinutes = durationInSeconds / 60;

      // Calculate price based on distance and travel mode
      double price = baseFare;

      switch (travelMode) {
        case 'driving':
          price += distanceInKm * pricePerKm;
          // Add surge pricing during peak hours
          final now = DateTime.now();
          if ((now.hour >= 7 && now.hour <= 9) ||
              (now.hour >= 17 && now.hour <= 19)) {
            price *= 1.2; // 20% surge during peak hours
          }
          break;
        case 'bicycling':
          price +=
              distanceInKm * (pricePerKm * 0.7); // Cheaper rate for bicycling
          break;
        case 'walking':
          price +=
              distanceInKm * (pricePerKm * 0.5); // Cheapest rate for walking
          break;
        case 'transit':
          price +=
              distanceInKm * (pricePerKm * 0.8); // Reduced rate for transit
          break;
      }

      // Calculate ETA
      DateTime now = DateTime.now();
      DateTime eta = now.add(Duration(seconds: durationInSeconds.toInt()));

      // Format ETA
      String formattedEta =
          "${eta.hour}:${eta.minute.toString().padLeft(2, '0')}";

      // Return all details
      return {
        'distance': directions['distance'],
        'distanceInKm': distanceInKm.toStringAsFixed(2),
        'duration': directions['duration'],
        'durationInMinutes': durationInMinutes.toStringAsFixed(0),
        'price': price.toStringAsFixed(2),
        'eta': formattedEta,
        'travelMode': travelMode,
        'polylinePoints': directions['overviewPolyline'],
      };
    } catch (e) {
      print('Error calculating route details: $e');

      // Return default values if we have an error
      return {
        'distance': 'Unknown',
        'distanceInKm': '0',
        'duration': 'Unknown',
        'durationInMinutes': '0',
        'price': '0.00',
        'eta': 'Unknown',
        'travelMode': travelMode,
        'polylinePoints': '',
      };
    }
  }

  //------------------------------------------------------------- STEP 9: IMPLEMENT MULTIPLE DROP-OFFS AND POLYLINES FOR MULTIPLE ROUTES
  Future<List<Map<String, dynamic>>> calculateMultiStopRoute({
    required LatLng origin,
    required List<LatLng> stops,
    required LatLng finalDestination,
    String travelMode = 'driving',
    double pricePerKm = 1.5,
    double baseFare = 2.0,
  }) async {
    List<Map<String, dynamic>> routes = [];

    try {
      // First leg: origin to first stop
      if (stops.isNotEmpty) {
        var firstLeg = await calculateRouteDetails(
          origin: origin,
          destination: stops.first,
          travelMode: travelMode,
          pricePerKm: pricePerKm,
          baseFare: baseFare,
        );
        routes.add({
          ...firstLeg,
          'from': 'Origin',
          'to': 'Stop 1',
          'fromPosition': origin,
          'toPosition': stops.first,
        });

        // Middle legs: between stops
        for (int i = 0; i < stops.length - 1; i++) {
          var midLeg = await calculateRouteDetails(
            origin: stops[i],
            destination: stops[i + 1],
            travelMode: travelMode,
            pricePerKm: pricePerKm,
            baseFare: 0, // No base fare for intermediate legs
          );
          routes.add({
            ...midLeg,
            'from': 'Stop ${i + 1}',
            'to': 'Stop ${i + 2}',
            'fromPosition': stops[i],
            'toPosition': stops[i + 1],
          });
        }

        // Final leg: last stop to final destination
        var finalLeg = await calculateRouteDetails(
          origin: stops.last,
          destination: finalDestination,
          travelMode: travelMode,
          pricePerKm: pricePerKm,
          baseFare: 0, // No base fare for final leg
        );
        routes.add({
          ...finalLeg,
          'from': 'Stop ${stops.length}',
          'to': 'Destination',
          'fromPosition': stops.last,
          'toPosition': finalDestination,
        });
      } else {
        // Direct route if no stops
        var directRoute = await calculateRouteDetails(
          origin: origin,
          destination: finalDestination,
          travelMode: travelMode,
          pricePerKm: pricePerKm,
          baseFare: baseFare,
        );
        routes.add({
          ...directRoute,
          'from': 'Origin',
          'to': 'Destination',
          'fromPosition': origin,
          'toPosition': finalDestination,
        });
      }

      // Calculate total distance, duration, and price
      double totalDistance = 0;
      double totalDuration = 0;
      double totalPrice = 0;

      for (var route in routes) {
        totalDistance += double.parse(route['distanceInKm']);
        totalDuration += double.parse(route['durationInMinutes']);
        totalPrice += double.parse(route['price']);
      }

      // Add total summary as the first item
      routes.insert(0, {
        'totalDistance': totalDistance.toStringAsFixed(2),
        'totalDuration': totalDuration.toStringAsFixed(0),
        'totalPrice': totalPrice.toStringAsFixed(2),
        'stops': stops.length,
        'isSummary': true,
      });

      return routes;
    } catch (e) {
      print('Error calculating multi-stop route: $e');
      return routes;
    }
  }

  //-------------------------------------------------------------- Draw all routes on the map
  Future<void> drawMultiStopRoute({
    required LatLng origin,
    required List<LatLng> stops,
    required LatLng finalDestination,
    String travelMode = 'driving',
    List<Color> colors = const [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ],
  }) async {
    try {
      // Clear existing polylines
      _polylines.clear();

      // Clear existing markers
      _markers.clear();

      // Add origin marker
      addMarker(
        markerId: 'origin',
        position: origin,
        title: 'Starting Point',
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );

      // Add stop markers
      for (int i = 0; i < stops.length; i++) {
        addMarker(
          markerId: 'stop_$i',
          position: stops[i],
          title: 'Stop ${i + 1}',
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow,
          ),
        );
      }

      // Add destination marker
      addMarker(
        markerId: 'destination',
        position: finalDestination,
        title: 'Final Destination',
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      // First leg: origin to first stop
      if (stops.isNotEmpty) {
        await addPolyline(
          origin: origin,
          destination: stops.first,
          polylineId: 'route_0',
          color: colors[0 % colors.length],
          travelMode: travelMode,
        );

        // Middle legs: between stops
        for (int i = 0; i < stops.length - 1; i++) {
          await addPolyline(
            origin: stops[i],
            destination: stops[i + 1],
            polylineId: 'route_${i + 1}',
            color: colors[(i + 1) % colors.length],
            travelMode: travelMode,
          );
        }

        // Final leg: last stop to final destination
        await addPolyline(
          origin: stops.last,
          destination: finalDestination,
          polylineId: 'route_${stops.length}',
          color: colors[stops.length % colors.length],
          travelMode: travelMode,
        );
      } else {
        // Direct route if no stops
        await addPolyline(
          origin: origin,
          destination: finalDestination,
          polylineId: 'direct_route',
          color: colors[0],
          travelMode: travelMode,
        );
      }
    } catch (e) {
      print('Error drawing multi-stop route: $e');
    }
  }

  //------------------------------------------ STEP 10: REAL-TIME UPDATES AND TRACKING
  Future<void> startLocationTracking({
    Function(Position)? onLocationUpdate,
    int interval = 5, // Seconds
  }) async {
    try {
      // Cancel any existing subscription
      await _positionStreamSubscription?.cancel();

      // Start a new subscription
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update if moved 10 meters
          timeLimit: Duration(seconds: 10),
        ),
      ).listen((Position position) {
        // Update current position
        _currentPosition = position;

        // Add to stream
        locationStreamController.add(position);

        // Call callback if provided
        if (onLocationUpdate != null) {
          onLocationUpdate(position);
        }

        // Update marker for current location if needed
        if (_markers.containsKey('current_location')) {
          addMarker(
            markerId: 'current_location',
            position: LatLng(position.latitude, position.longitude),
            title: 'Current Location',
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          );
        }

        // If we have a map controller, center on current location
        if (mapController != null) {
          _animateToPosition(LatLng(position.latitude, position.longitude));
        }
      });
    } catch (e) {
      print('Error starting location tracking: $e');
    }
  }

  //----------------------------------------------------- Start sharing location with a specific ID
  Future<void> startLocationSharing(String userId) async {
    try {
      // Set up WebSocket connection
      final uri = Uri.parse('wss://your-tracking-server.com/track/$userId');
      _trackingChannel = WebSocketChannel.connect(uri);

      // Start location tracking if not already started
      if (_positionStreamSubscription == null) {
        await startLocationTracking(
          onLocationUpdate: (position) {
            // Send location updates through WebSocket
            _trackingChannel?.sink.add(
              jsonEncode({
                'userId': userId,
                'latitude': position.latitude,
                'longitude': position.longitude,
                'speed': position.speed,
                'heading': position.heading,
                'timestamp': DateTime.now().toIso8601String(),
              }),
            );
          },
        );
      }
    } catch (e) {
      print('Error starting location sharing: $e');
    }
  }

  // Stop sharing location
  void stopLocationSharing() {
    _trackingChannel?.sink.close();
    _trackingChannel = null;
  }

  //-------------------------------- Listen to shared location updates from another user
  Stream<Map<String, dynamic>> listenToSharedLocation(String userId) {
    try {
      final uri = Uri.parse('wss://your-tracking-server.com/listen/$userId');
      final channel = WebSocketChannel.connect(uri);

      return channel.stream.map((event) {
        final data = jsonDecode(event);
        return data;
      });
    } catch (e) {
      print('Error listening to shared location: $e');
      return Stream.empty();
    }
  }

  //--------------------------------- ADDITIONAL FEATURE 1: REAL-TIME TRAFFIC OVERLAY
  void toggleTrafficLayer(bool show) {
    if (mapController != null) {
      // Use trafficEnabled property in the GoogleMap widget instead
      // Update the trafficEnabled state and rebuild the map
      _trafficEnabled = show;
    }
  }

  // ADDITIONAL FEATURE 2: ESTIMATED ARRIVAL TIME (ETA)
  Future<String> getEstimatedArrivalTime({
    required LatLng origin,
    required LatLng destination,
    String travelMode = 'driving',
  }) async {
    try {
      Map<String, dynamic> routeDetails = await calculateRouteDetails(
        origin: origin,
        destination: destination,
        travelMode: travelMode,
      );

      return routeDetails['eta'];
    } catch (e) {
      print('Error getting ETA: $e');
      return 'Unknown';
    }
  }

  //------------------------------------------------------------ ADDITIONAL FEATURE 3: MAP THEMES
  bool _isDarkMode(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  // Apply dark map style
  Future<void> _setDarkMapStyle(GoogleMapController controller) async {
    const darkMapStyle = '''[
      {
        "elementType": "geometry",
        "stylers": [{"color": "#212121"}]
      },
      {
        "elementType": "labels.icon",
        "stylers": [{"visibility": "off"}]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#757575"}]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [{"color": "#212121"}]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry",
        "stylers": [{"color": "#757575"}]
      },
      {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [{"color": "#616161"}]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#757575"}]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [{"color": "#383838"}]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#8a8a8a"}]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [{"color": "#616161"}]
      },
      {
        "featureType": "road.highway",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#f3d19c"}]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [{"color": "#000000"}]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#3d3d3d"}]
      }
    ]''';

    await controller.setMapStyle(darkMapStyle);
  }

  // Step 11: Map Themes Implementation
  final Map<String, String> mapThemes = {
    'standard': '[]', // Default Google Maps style
    'night': '''[
    {
      "elementType": "geometry",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#746855"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [{"color": "#263c3f"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#6b9a76"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#38414e"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#212a37"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#9ca5b3"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#746855"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#1f2835"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#f3d19c"}]
    },
    {
      "featureType": "transit",
      "elementType": "geometry",
      "stylers": [{"color": "#2f3948"}]
    },
    {
      "featureType": "transit.station",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#17263c"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#515c6d"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#17263c"}]
    }
  ]''',
    'silver': '''[
    {
      "elementType": "geometry",
      "stylers": [{"color": "#f5f5f5"}]
    },
    {
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#616161"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#f5f5f5"}]
    },
    {
      "featureType": "administrative.land_parcel",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#bdbdbd"}]
    },
    {
      "featureType": "poi",
      "elementType": "geometry",
      "stylers": [{"color": "#eeeeee"}]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [{"color": "#e5e5e5"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#9e9e9e"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#ffffff"}]
    },
    {
      "featureType": "road.arterial",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#dadada"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#616161"}]
    },
    {
      "featureType": "road.local",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#9e9e9e"}]
    },
    {
      "featureType": "transit.line",
      "elementType": "geometry",
      "stylers": [{"color": "#e5e5e5"}]
    },
    {
      "featureType": "transit.station",
      "elementType": "geometry",
      "stylers": [{"color": "#eeeeee"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#c9c9c9"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#9e9e9e"}]
    }
  ]''',
  };

  //----------------------------------------------------------------- Apply map theme
  Future<void> setMapTheme(String themeName) async {
    if (mapController != null && mapThemes.containsKey(themeName)) {
      await mapController!.setMapStyle(mapThemes[themeName]);

      // Save user preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('map_theme', themeName);
    }
  }

  // Load saved theme preference
  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('map_theme') ?? 'standard';
    await setMapTheme(savedTheme);
  }

  //------------------------------------------- Step 12: Real-Time Traffic Overlay
  bool _trafficEnabled = false;

  void toggleTrafficOverlay() {
    if (mapController != null) {
      _trafficEnabled = !_trafficEnabled;
      // Rebuild the map with the updated trafficEnabled state
      _trafficEnabled = !_trafficEnabled;
      mapController?.setMapStyle(null); // Optionally reset map style if needed
    }
  }

  //----------------------------------------------- Step 13: Estimated Arrival Time (ETA)
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> calculateETA(
    LatLng origin,
    LatLng destination,
    String travelMode,
  ) async {
    try {
      var response = await _dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode':
              travelMode.toLowerCase(), // driving, walking, bicycling, transit
          'departure_time': 'now',
          'traffic_model': 'best_guess', // best_guess, pessimistic, optimistic
          'key': googleApiKey,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        var route = response.data['routes'][0];
        var leg = route['legs'][0];

        return {
          'distance': leg['distance']['text'],
          'distance_value': leg['distance']['value'], // in meters
          'duration': leg['duration']['text'],
          'duration_value': leg['duration']['value'], // in seconds
          'duration_in_traffic':
              leg['duration_in_traffic']?['text'] ?? leg['duration']['text'],
          'duration_in_traffic_value':
              leg['duration_in_traffic']?['value'] ?? leg['duration']['value'],
          'start_address': leg['start_address'],
          'end_address': leg['end_address'],
          'polyline_points': route['overview_polyline']['points'],
        };
      } else {
        throw Exception('Failed to calculate ETA: ${response.data['status']}');
      }
    } catch (e) {
      throw Exception('Failed to calculate ETA: $e');
    }
  }

  //----------------------------------------------------------- Step 14: Location Sharing
  // Generate shareable link for current location
  Future<String> generateLocationSharingLink(
    Position position, {
    String? name,
  }) async {
    try {
      // Create a shortened URL using a URL shortener service or your backend
      final locationData = {
        'lat': position.latitude,
        'lng': position.longitude,
        'name': name ?? 'My Location',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // This is a placeholder - you would implement your own URL generation logic
      // For example, sending this data to your backend and getting a shortened URL
      String encodedData = Uri.encodeComponent(json.encode(locationData));
      return 'https://yourapp.com/location?data=$encodedData';
    } catch (e) {
      throw Exception('Failed to generate sharing link: $e');
    }
  }

  //---------------------------------------------------- Parse shared location from a link
  Future<Map<String, dynamic>> parseSharedLocation(String url) async {
    try {
      Uri uri = Uri.parse(url);
      String? encodedData = uri.queryParameters['data'];

      if (encodedData != null) {
        Map<String, dynamic> locationData = json.decode(
          Uri.decodeComponent(encodedData),
        );
        return locationData;
      } else {
        throw Exception('Invalid location sharing link');
      }
    } catch (e) {
      throw Exception('Failed to parse shared location: $e');
    }
  }

  //-------------------------------------------------------- Step 15: Geofencing
  // Add a geofence
  Future<void> addGeofence(
    LatLng center,
    double radius,
    String id, {
    Color color = Colors.blue,
  }) async {
    _geofenceCircles.add(
      Circle(
        circleId: CircleId(id),
        center: center,
        radius: radius,
        fillColor: color.withOpacity(0.3),
        strokeColor: color,
        strokeWidth: 2,
      ),
    );

    // Start monitoring geofence
    _startGeofenceMonitoring(center, radius, id);
  }

  // Remove a geofence
  void removeGeofence(String id) {
    _geofenceCircles.removeWhere((circle) => circle.circleId.value == id);
    // Stop monitoring for this geofence
    // Implementation depends on how you're monitoring geofences
  }

  // Monitor geofence
  void _startGeofenceMonitoring(LatLng center, double radius, String id) {
    locationStreamController.stream.listen((Position position) {
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        center.latitude,
        center.longitude,
      );

      bool isInside = distanceInMeters <= radius;
      _checkGeofenceTransition(id, isInside);
    });
  }

  // Track geofence state to detect transitions
  Map<String, bool> _geofenceState = {};

  void _checkGeofenceTransition(String id, bool isInside) {
    // Check if this is the first time we're tracking this geofence
    if (!_geofenceState.containsKey(id)) {
      _geofenceState[id] = isInside;
      _onGeofenceStatusChanged(id, isInside ? 'ENTER' : 'OUTSIDE');
    }
    // Check if state changed
    else if (_geofenceState[id] != isInside) {
      _geofenceState[id] = isInside;
      _onGeofenceStatusChanged(id, isInside ? 'ENTER' : 'EXIT');
    }
  }

  void _onGeofenceStatusChanged(String id, String transitionType) {
    // Notify listeners about geofence transition
    // This could trigger a notification, log the event, etc.
    print('Geofence $id: $transitionType');

    // Add your notification logic here
    // For example, showing a local notification when user enters or exits a geofence
  }

  //------------------------------------------------------------------- Step 16: Offline Maps
  // Cache map data for offline use
  Future<void> cacheMapForOfflineUse(LatLngBounds bounds, int zoomLevel) async {
    try {
      // Get map tiles for the specified area
      // This is a simplified approach - a real implementation would download actual map tiles

      // Get places within the area
      var placesResponse = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
        queryParameters: {
          'location':
              '${bounds.northeast.latitude},${bounds.northeast.longitude}',
          'radius': '5000', // 5km radius
          'key': googleApiKey,
        },
      );

      // Get roads and routes within the area
      var roadsResponse = await _dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin':
              '${bounds.southwest.latitude},${bounds.southwest.longitude}',
          'destination':
              '${bounds.northeast.latitude},${bounds.northeast.longitude}',
          'key': googleApiKey,
        },
      );

      // Save data to local storage
      _offlineMapData = {
        'bounds': {
          'ne': {
            'lat': bounds.northeast.latitude,
            'lng': bounds.northeast.longitude,
          },
          'sw': {
            'lat': bounds.southwest.latitude,
            'lng': bounds.southwest.longitude,
          },
        },
        'zoom': zoomLevel,
        'places': placesResponse.data['results'],
        'roads': roadsResponse.data['routes'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Store in SharedPreferences or a database
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('offline_map_data', json.encode(_offlineMapData));
    } catch (e) {
      throw Exception('Failed to cache map data: $e');
    }
  }

  // Load offline map data
  Future<bool> loadOfflineMapData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? storedData = prefs.getString('offline_map_data');

      if (storedData != null) {
        _offlineMapData = json.decode(storedData);
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to load offline map data: $e');
      return false;
    }
  }

  // Use offline data to show map when there's no internet connection
  Widget buildOfflineMap() {
    if (_offlineMapData.isEmpty) {
      return Center(child: Text('No offline map data available'));
    }

    // Create a static map using the cached data
    final bounds = _offlineMapData['bounds'];
    final places = _offlineMapData['places'] as List;

    return Stack(
      children: [
        Image.network(
          'https://maps.googleapis.com/maps/api/staticmap?center=${bounds['ne']['lat']},${bounds['ne']['lng']}&zoom=${_offlineMapData['zoom']}&size=600x400&key=$googleApiKey',
          errorBuilder: (context, error, stackTrace) {
            // Fallback to a plain representation if image can't be loaded
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: Text('Offline Map - ${places.length} places available'),
              ),
            );
          },
        ),
        // You could overlay custom markers and routes here using the cached data
      ],
    );
  }

  // Fix for Error 3: Define `_cacheRouteData` method
  void _cacheRouteData(Map<String, dynamic> directionInfo) {
    // Implement caching logic here
    _offlineMapData['routes'] = directionInfo;
  }
}
