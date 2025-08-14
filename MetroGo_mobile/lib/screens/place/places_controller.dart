// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesController extends ChangeNotifier {
  final String googleApiKey = 'AIzaSyBoWy2-vzkQzOw9FrCKUyfxWpa5_dsPi10';
  bool isLoading = false;
  List<dynamic> searchResults = [];
  List<dynamic> nearbyPlaces = [];
  Position? userLocation;
  String? selectedCategory;
  Map<String, dynamic>? placeDetails;

  // Fetch current location
  Future<void> getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Handle permission denied
        return;
      }
    }

    if (permission == LocationPermission.denied) {
      // Handle permission denied
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      userLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await getNearbyPlaces();
    } catch (error) {
      print("Error getting location: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Search for places using Google Places API
  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await Dio().get(
        'https://maps.googleapis.com/maps/api/place/textsearch/json',
        queryParameters: {
          'query': query,
          'key': googleApiKey,
          if (userLocation != null) 'location': '${userLocation!.latitude},${userLocation!.longitude}',
          if (userLocation != null) 'radius': 50000, // 50km radius
        },
      );
      
      searchResults = response.data['results'];
      
      // If a category is selected, filter the results
      if (selectedCategory != null) {
        searchResults = searchResults.where((place) => 
          place['types'] != null && place['types'].contains(selectedCategory)
        ).toList();
      }
    } catch (error) {
      print("Error fetching search results: $error");
    }

    isLoading = false;
    notifyListeners();
  }

  // Clear search results
  void clearSearch() {
    searchResults = [];
    notifyListeners();
  }

  // Get nearby places using the current location
  Future<void> getNearbyPlaces() async {
    if (userLocation == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await Dio().get(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
        queryParameters: {
          'location': '${userLocation!.latitude},${userLocation!.longitude}',
          'radius': 5000, // 5km radius
          'key': googleApiKey,
          if (selectedCategory != null) 'type': selectedCategory,
        },
      );
      
      nearbyPlaces = response.data['results'];
    } catch (error) {
      print("Error fetching nearby places: $error");
    }

    isLoading = false;
    notifyListeners();
  }

  // Filter places by category
  void filterPlacesByCategory(String category) {
    // Toggle category if it's already selected
    if (selectedCategory == category) {
      selectedCategory = null;
    } else {
      selectedCategory = category;
    }
    
    // If there are search results, filter them by the selected category
    if (searchResults.isNotEmpty) {
      if (selectedCategory != null) {
        final filteredResults = searchResults.where((place) => 
          place['types'] != null && place['types'].contains(selectedCategory)
        ).toList();
        
        // Only update if there are matching results, otherwise keep the current results
        if (filteredResults.isNotEmpty) {
          searchResults = filteredResults;
        }
      } else {
        // If no category is selected, do a fresh search with the existing query
        if (_lastSearchQuery.isNotEmpty) {
          searchPlaces(_lastSearchQuery);
        }
      }
    } else {
      // If no search results, filter nearby places
      getNearbyPlaces();
    }
    
    notifyListeners();
  }
  
  // Store the last search query
  final String _lastSearchQuery = '';
  
  // Get place details by place ID
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    isLoading = true;
    notifyListeners();
    
    try {
      final response = await Dio().get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': googleApiKey,
          'fields': 'name,rating,formatted_phone_number,formatted_address,geometry,opening_hours,photos,reviews,website,price_level,vicinity,types'
        },
      );
      
      if (response.data['status'] == 'OK') {
        placeDetails = response.data['result'];
        return placeDetails!;
      } else {
        throw Exception('Failed to load place details: ${response.data['status']}');
      }
    } catch (error) {
      print("Error fetching place details: $error");
      throw error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

final placesControllerProvider = ChangeNotifierProvider<PlacesController>(
  (ref) => PlacesController(),
);