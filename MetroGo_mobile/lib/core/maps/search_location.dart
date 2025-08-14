import 'package:datride_mobile/screens/book_ride/book_ride_mode.dart';
import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_maps_webservices/geocoding.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_google_maps_webservices/timezone.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final List<TextEditingController> _extraDropOffControllers = [];
  final FocusNode _pickupFocus = FocusNode();
  final FocusNode _destinationFocus = FocusNode();
  final List<FocusNode> _extraDropOffFocusNodes = [];

  List<PlacesSearchResult> _searchResults = [];
  bool _isLoading = false;
  int _activeFieldIndex = 1; // 0 = pickup, 1 = destination, 2+ = extra dropoffs

  late GoogleMapsPlaces _places;
  late GoogleMapsGeocoding _geocoding;
  // late GoogleMapsTimezone _timezone;
  late Timer _debounceTimer;

  @override
  void initState() {
    super.initState();

    // Initialize Places, Geocoding, and Timezone APIs with your API key
    _places = GoogleMapsPlaces(
      apiKey: 'AIzaSyBoWy2-vzkQzOw9FrCKUyfxWpa5_dsPi10',
    );
    _geocoding = GoogleMapsGeocoding(
      apiKey: 'AIzaSyBoWy2-vzkQzOw9FrCKUyfxWpa5_dsPi10',
    );
    // _timezone = GoogleMapsTimezone(apiKey: 'AIzaSyBoWy2-vzkQzOw9FrCKUyfxWpa5_dsPi10');

    // Setup status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Initialize debounce timer
    _debounceTimer = Timer(Duration.zero, () {});

    // Add listeners to text controllers
    _pickupController.addListener(_onTextChanged);
    _destinationController.addListener(_onTextChanged);

    // Auto-focus destination field initially
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_destinationFocus);
      }
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    for (var controller in _extraDropOffControllers) {
      controller.dispose();
    }

    _pickupFocus.dispose();
    _destinationFocus.dispose();
    for (var node in _extraDropOffFocusNodes) {
      node.dispose();
    }

    _debounceTimer.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    // Cancel previous timer
    _debounceTimer.cancel();

    // Start new timer for debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    String query = '';

    if (_pickupFocus.hasFocus) {
      query = _pickupController.text;
      _activeFieldIndex = 0;
    } else if (_destinationFocus.hasFocus) {
      query = _destinationController.text;
      _activeFieldIndex = 1;
    } else {
      for (int i = 0; i < _extraDropOffFocusNodes.length; i++) {
        if (_extraDropOffFocusNodes[i].hasFocus) {
          query = _extraDropOffControllers[i].text;
          _activeFieldIndex = i + 2;
          break;
        }
      }
    }

    if (query.length < 2) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Perform Places API search
      final response = await _places.searchByText(query);

      if (response.status == 'OK') {
        setState(() {
          _searchResults = response.results;
          _isLoading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  void _addExtraDropOff() {
    if (_extraDropOffControllers.length >= 3) {
      // Maximum 3 extra dropoffs - use Toast instead of Snackbar
      Fluttertoast.showToast(
        msg: "Maximum 3 extra stops allowed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey.shade800,
        textColor: Colors.white,
      );
      return;
    }

    final controller = TextEditingController();
    final focusNode = FocusNode();

    controller.addListener(_onTextChanged);

    setState(() {
      _extraDropOffControllers.add(controller);
      _extraDropOffFocusNodes.add(focusNode);
    });

    // Focus the newly added field
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(focusNode);
      }
    });
  }

  void _removeExtraDropOff(int index) {
    setState(() {
      _extraDropOffControllers[index].dispose();
      _extraDropOffFocusNodes[index].dispose();
      _extraDropOffControllers.removeAt(index);
      _extraDropOffFocusNodes.removeAt(index);
    });
  }

  void _selectSearchResult(PlacesSearchResult result) async {
    String placeName = result.name;
    if (result.formattedAddress != null &&
        result.formattedAddress!.isNotEmpty) {
      placeName = "${result.name}, ${result.formattedAddress}";
    }

    if (_activeFieldIndex == 0) {
      _pickupController.text = placeName;
      // Move focus to destination if empty
      if (_destinationController.text.isEmpty) {
        FocusScope.of(context).requestFocus(_destinationFocus);
      }
    } else if (_activeFieldIndex == 1) {
      _destinationController.text = placeName;
      // If both fields have values, show the confirmation sheet
      if (_pickupController.text.isNotEmpty) {
        _showConfirmationSheet();
      } else {
        // Move focus to pickup if empty
        FocusScope.of(context).requestFocus(_pickupFocus);
      }
    } else {
      final dropOffIndex = _activeFieldIndex - 2;
      if (dropOffIndex < _extraDropOffControllers.length) {
        _extraDropOffControllers[dropOffIndex].text = placeName;
      }
    }

    // Clear search results after selection
    setState(() {
      _searchResults = [];
    });
  }

  void _showConfirmationSheet() {
    // Check if all required fields are filled
    bool allFilled =
        _pickupController.text.isNotEmpty &&
        _destinationController.text.isNotEmpty;

    for (var controller in _extraDropOffControllers) {
      if (controller.text.isEmpty) {
        allFilled = false;
        break;
      }
    }

    if (!allFilled) {
      return;
    }

    // Build route data
    final routeData = {
      'pickup': {'name': _pickupController.text},
      'destination': {'name': _destinationController.text},
      'extraDropOffs':
          _extraDropOffControllers.map((controller) {
            return {'name': controller.text};
          }).toList(),
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildConfirmationSheet(routeData),
    );
  }

  void _onFieldUpdated() {
    // Trigger confirmation popup if the last additional location or destination is entered
    if (_destinationController.text.isNotEmpty &&
        _pickupController.text.isNotEmpty &&
        (_extraDropOffControllers.isEmpty ||
            _extraDropOffControllers.last.text.isNotEmpty)) {
      _showConfirmationSheet();
    }
  }

  Future<void> _fillWithCurrentLocation(
    TextEditingController controller,
  ) async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(
          msg: "Location permission denied",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey.shade800,
          textColor: Colors.white,
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get address
      final response = await _geocoding.searchByLocation(
        Location(lat: position.latitude, lng: position.longitude),
      );

      if (response.status == 'OK' && response.results.isNotEmpty) {
        final address = response.results.first.formattedAddress ?? '';
        setState(() {
          controller.text = address;
        });

        // Trigger bottom sheet if all required fields are filled
        _onFieldUpdated();
      } else {
        Fluttertoast.showToast(
          msg: "Unable to fetch address",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey.shade800,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching location: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey.shade800,
        textColor: Colors.white,
      );
    }
  }

  Widget _buildConfirmationSheet(Map<String, dynamic> routeData) {
    // final isDarkMode = THelperFunctions.isDarkMode(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.6, // Reduced size
      minChildSize: 0.6,
      maxChildSize: 0.75,
      snap: true,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withOpacity(0.8),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Confirm Your Route',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Route details
                  _buildRouteDetailsItem(
                    icon: Icons.my_location,
                    title: 'Pickup',
                    description: routeData['pickup']['name'],
                    iconColor: Colors.green,
                  ),

                  if (routeData['extraDropOffs'].isNotEmpty) ...[
                    for (int i = 0; i < routeData['extraDropOffs'].length; i++)
                      _buildRouteDetailsItem(
                        icon: Icons.place,
                        title: 'Stop ${i + 1}',
                        description: routeData['extraDropOffs'][i]['name'],
                        iconColor: Colors.orange,
                      ),
                  ],

                  _buildRouteDetailsItem(
                    icon: Icons.location_on,
                    title: 'Destination',
                    description: routeData['destination']['name'],
                    iconColor: Colors.red,
                    isLast: true,
                  ),

                  const SizedBox(height: 20),

                  // Info text
                  Center(
                    child: Text(
                      'Estimated fare: \$25.50 - \$30.00',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Proceed button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookRideMode(),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Proceed',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRouteDetailsItem({
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            if (!isLast)
              Container(width: 2, height: 24, color: Colors.grey.shade700),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isLast ? 0 : 12),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 56,
        title: Text(
          'Set Your Route',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDarkMode
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey.shade800, Colors.grey.shade900],
                  )
                  : null,
          color: isDarkMode ? null : Colors.grey.shade100,
        ),
        child: Column(
          children: [
            // Search fields container
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? Colors.grey.shade900.withOpacity(0.8)
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDarkMode
                            ? Colors.black.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Pickup field
                  SizedBox(
                    height: 36,
                    child: TextField(
                      controller: _pickupController,
                      focusNode: _pickupFocus,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter pickup location',
                        hintStyle: TextStyle(
                          color:
                              isDarkMode
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade700,
                          fontSize: 14,
                        ),
                        prefixIcon: GestureDetector(
                          onTap:
                              () => _fillWithCurrentLocation(_pickupController),
                          child: Icon(
                            Icons.my_location,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color:
                                isDarkMode
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                          ),
                        ),
                        filled: true,
                        fillColor:
                            isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Destination field
                  SizedBox(
                    height: 36,
                    child: TextField(
                      controller: _destinationController,
                      focusNode: _destinationFocus,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter destination',
                        hintStyle: TextStyle(
                          color:
                              isDarkMode
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade700,
                          fontSize: 14,
                        ),
                        prefixIcon: GestureDetector(
                          onTap:
                              () => _fillWithCurrentLocation(
                                _destinationController,
                              ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color:
                                isDarkMode
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                          ),
                        ),
                        filled: true,
                        fillColor:
                            isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Extra drop-off fields
                  for (int i = 0; i < _extraDropOffControllers.length; i++) ...[
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: TextField(
                              controller: _extraDropOffControllers[i],
                              focusNode: _extraDropOffFocusNodes[i],
                              onChanged: (_) => setState(() {}),
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter stop ${i + 1}',
                                hintStyle: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.grey.shade500
                                          : Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                                prefixIcon: GestureDetector(
                                  onTap:
                                      () => _fillWithCurrentLocation(
                                        _extraDropOffControllers[i],
                                      ),
                                  child: Icon(
                                    Icons.place,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color:
                                        isDarkMode
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade400,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                            size: 18,
                          ),
                          onPressed: () => _removeExtraDropOff(i),
                          padding: EdgeInsets.all(4),
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 3),
                  ],

                  // Add extra drop-off button
                  TextButton.icon(
                    onPressed: _addExtraDropOff,
                    icon: Icon(Icons.add, color: Colors.purple, size: 16),
                    label: Text(
                      'Add Stop',
                      style: TextStyle(color: Colors.purple, fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed:
                      (_pickupController.text.isNotEmpty &&
                              _destinationController.text.isNotEmpty)
                          ? _showConfirmationSheet
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Divider(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                height: 1,
              ),
            ),

            // Search results
            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.purple,
                            ),
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _searchResults.length,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return Card(
                            color:
                                isDarkMode
                                    ? Colors.grey.shade800.withOpacity(0.8)
                                    : Colors.grey.shade200,
                            elevation: 0,
                            margin: EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color:
                                    isDarkMode
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade400,
                                width: 0.5,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              title: Text(
                                result.name,
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                result.formattedAddress ?? '',
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                _selectSearchResult(result);
                                _onFieldUpdated();
                              },
                              dense: true,
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
