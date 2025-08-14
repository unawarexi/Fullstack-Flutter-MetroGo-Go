import 'package:datride_mobile/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:datride_mobile/core/maps/map_controller.dart';
import 'dart:ui';

class BookRideMap extends StatefulWidget {
  const BookRideMap({super.key});

  @override
  State<BookRideMap> createState() => _BookRideMapState();
}

class _BookRideMapState extends State<BookRideMap>
    with TickerProviderStateMixin {
  late GoogleMapController _mapController;
  final Location _location = Location();
  final Set<Marker> markers = {};

  final bool _isSearching = true;
  late AnimationController _radarController;
  Timer? _searchTimer;

  String _selectedCarType = 'Sedan'; // Default value
  String _selectedRideType = 'Standard'; // Default value
 // Updated to ensure type safety
  final List<Map<String, String>> _carTypes = [
    {'type': 'Sedan', 'image': TImages.sedan}, 
    {'type': 'SUV', 'image': TImages.suv }, 
    {'type': 'Luxury', 'image': TImages.lux}, 
    {'type': 'Minivan', 'image': TImages.minivan}, 
    {'type': 'EcoBus', 'image': TImages.grouptrip},
  ];

  final List<String> _rideTypes = ['Standard', 'Premium', 'DatSave', 'XL'];

  // Driver Simulation
  final List<Map<String, dynamic>> _nearbyDrivers = [
    {
      'name': 'John Doe',
      'rating': 4.8,
      'carModel': 'Toyota Camry',
      'distance': 2.5,
      'eta': 5,
    },
    {
      'name': 'Emma Smith',
      'rating': 4.9,
      'carModel': 'Honda Accord',
      'distance': 3.2,
      'eta': 7,
    },
  ];

  double _progressValue = 0.0;
  String _progressText = 'Looking for a driver...';
  final List<String> _progressMessages = [
    'Looking for a driver...',
    'Driver found!',
    'Searching for another driver...',
    'Still looking for a driver...',
  ];
  Timer? _progressTimer;
  // ignore: unused_field
  bool _isTimeout = false;
  bool _showTryAgainButton = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _initializeRadarAnimation();
    _startProgressSimulation();
  }

  void _initializeMap() async {
    final permissionGranted = await _location.requestPermission();
    if (permissionGranted == PermissionStatus.granted) {
      await _location.requestService();
      _goToCurrentLocation();
    }
  }

  void _initializeRadarAnimation() {
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void _startProgressSimulation() {
    _progressTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _progressValue += 0.2;
        if (_progressValue >= 1.0) {
          _progressValue = 0.0; // Reset progress for testing
          _isTimeout = true; // Trigger timeout
          _showTimeoutModal(); // Show timeout modal
          timer.cancel(); // Stop the timer
          _radarController.stop(); // Stop radar animation
        }
        _progressText = (_progressMessages..shuffle()).first; // Random text
      });
    });
  }

  void _goToCurrentLocation() async {
    final locationData = await _location.getLocation();
    if (locationData.latitude != null && locationData.longitude != null) {
      final currentPosition = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );

      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      );

      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentPosition, 15),
      );
    }
  }


// ---------------------------- Share ride function
  void _showShareRideOptions() {
    final isDarkMode = THelperFunctions.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20), // Adjusted border radius
        ),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20), // Ensure consistent border radius
          ),
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.purple.shade900, Colors.black]
                : [
                    const Color.fromARGB(255, 183, 70, 203),
                    Colors.white,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: 'RIDE_ID_12345',
              version: QrVersions.auto,
              size: 200.0,
              foregroundColor: isDarkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ride ID: RIDE_ID_12345',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Copy Ride ID
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy ID'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Share Ride ID
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// ---------------------------- time out modal
  void _showTimeoutModal() {
    final isDarkMode = THelperFunctions.isDarkMode(context);

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isDarkMode
                          ? [Colors.purple.shade900, Colors.black]
                          : [
                            const Color.fromARGB(255, 183, 70, 203),
                            Colors.white,
                          ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image at the top
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.asset(
                      TImages.notfound, // Replace with your image path
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Modal content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Text(
                          'Drivers Are Busy!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We couldn\'t find a driver. Would you like to keep searching or try again later?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _radarController
                                      .repeat(); // Restart radar animation
                                  _startProgressSimulation(); // Restart progress simulation
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Keep Searching'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _showTryAgainButton =
                                      true; // Show "Try Again" button
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Try Later'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }

//----------------------------------- Promo discount section
  Widget _buildPromoDiscountSection() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 0,
      ), // Add margin for spacing
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade300, Colors.deepPurple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Promo Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_offer, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          // Promo Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Promo Offer: 20% Off!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Enjoy 20% off your ride today.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  'No code needed!',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // Info Button
          
          ElevatedButton(
            onPressed: () {
              // Handle offer details
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Details'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    final mapStyle =
        isDarkMode
            ? MapController.darkPurpleMapStyle
            : MapController.lightPurpleMapStyle;

    return Scaffold(
      body: Stack(
        children: [
          //-------------------------------- Google Maps with Custom Style
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              _mapController.setMapStyle(mapStyle);
              _goToCurrentLocation();
            },
            markers: markers,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194),
              zoom: 14.0,
            ),
          ),

          //-------------------------------- Radar Effect with Centered Marker
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _radarController,
                    builder: (context, child) {
                      return Container(
                        width: 200 + _radarController.value * 100,
                        height: 200 + _radarController.value * 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple.withOpacity(
                            1 - _radarController.value * 0.8,
                          ),
                        ),
                      );
                    },
                  ),
                  const Icon(
                    Icons.location_pin,
                    color: Colors.purple,
                    size: 40,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          //------------------------------------ Progress Bar with Changing Text or "Try Again" Button
          Positioned(
            top: 70, 
            left: 20,
            right: 20,
            child: Column(
              children: [
                if (_showTryAgainButton)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showTryAgainButton = false; // Hide "Try Again" button
                        _progressValue = 0.0; // Reset progress bar
                        _radarController.repeat(); // Restart radar animation
                        _startProgressSimulation(); // Restart progress simulation
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple, // Purple background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white, // White text
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: _progressValue,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            20,
                          ), 
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode
                                        ? Colors.white.withOpacity(
                                          0.1,
                                        ) // Glass effect for dark mode
                                        : Colors.purple.withOpacity(
                                          0.2,
                                        ), // Glass effect for light mode
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                _progressText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.black, 
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          //---------------------------------------- Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? const Color(0xFF1D1D2C)
                          : const Color(0xFFF3F3F9),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Promo Code Section
                    _buildPromoDiscountSection(),
                    const SizedBox(height: 20),

                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Transport Selection
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Transport',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                         SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _carTypes.map((car) {
                // Ensure 'type' and 'image' are non-null
                final carType = car['type'] ?? '';
                final carImage = car['image'] ?? '';
                
                final isSelected = _selectedCarType == carType;
                return GestureDetector(
                  onTap: () {
                    if (_selectedCarType != carType) {
                      _showChangeCarTypeModal(carType);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.purple.shade300
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.purple : Colors.grey,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Use a placeholder if image is empty
                        carImage.isNotEmpty
                            ? Image.asset(
                                carImage,
                                width: 80,
                                height: 50,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.car_rental, size: 50);
                                },
                              )
                            : const Icon(Icons.car_rental, size: 50),
                        const SizedBox(height: 5),
                        Text(
                          carType,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _rideTypes.map((type) {
                                final isSelected = _selectedRideType == type;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: ChoiceChip(
                                    label: Text(type),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedRideType = type;
                                      });
                                    },
                                    selectedColor: Colors.purple.shade300,
                                    backgroundColor: Colors.grey.shade200,
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //----------------------------------------------- Search Status
                    if (_isSearching)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Searching for $_selectedCarType $_selectedRideType Ride',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                // View nearby drivers
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isDarkMode
                                        ? const Color(0xFF4B3992)
                                        : const Color(0xFFB39DDB),
                              ),
                              child: const Text('View Nearby Drivers'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          //-------------------------------------------------- Share Ride and Control Buttons
          if (!_isSearching)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.person_search),
                    label: const Text('Find Driver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Share ride implementation
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Ride'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

          //-------------------------------------------------- Share Ride Button
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _showShareRideOptions,
                icon: const Icon(Icons.share),
                label: const Text('Share Ride'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modify _showChangeCarTypeModal to handle null safety
  void _showChangeCarTypeModal(String newCarType) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Colors.purple.shade900, Colors.black]
                  : [Colors.purple.shade300, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Change Ride Type',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to change to $newCarType?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCarType = newCarType;
                        _selectedRideType = 'DatSave'; // Default ride type
                      });
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: const Text('Proceed'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    _radarController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }
}
