import 'package:datride_mobile/core/maps/map_controller.dart';
import 'package:datride_mobile/core/maps/search_location.dart';
import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late MapController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final PanelController _panelController = PanelController();

  @override
  void initState() {
    super.initState();

    _controller = MapController();

    // Set status bar to transparent with light icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Initialize map controller
    _controller.initializeMap();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      body: Stack(
        children: [
          // Map View
          _buildMapView(),

          // Status Bar Gradient Overlay (for better visibility of status bar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).padding.top + 20,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode ? [Colors.black.withOpacity(0.7), Colors.transparent] : [Colors.white.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),

          // App Bar with Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: _buildAppBar(),
          ),

          // Current Location Button
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.42,
            right: 20,
            child: _buildCurrentLocationButton(),
          ),

          // Sliding Panel
          SlidingUpPanel(
            controller: _panelController,
            minHeight: MediaQuery.of(context).size.height * 0.4,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
            boxShadow: [
              BoxShadow(
                color:
                    isDarkMode
                        ? Colors.black.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, -3),
              ),
            ],
            panelBuilder: (ScrollController sc) => _buildSlidingPanel(sc),
            onPanelSlide: (position) {
              _controller.panelPosition = position;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GoogleMap(
          initialCameraPosition: _controller.initialCameraPosition,
          myLocationEnabled: true,
          myLocationButtonEnabled: false, // We'll use our custom button
          compassEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          markers: _controller.markers,
          polylines: _controller.polylines,
          onMapCreated: (GoogleMapController controller) {
            _controller.onMapCreated(controller, context);
          },
          onTap: (LatLng position) {
            _controller.onMapTapped(position);
          },
        );
      },
    );
  }

  Widget _buildAppBar() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            // Back button
            Container(
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade900.withOpacity(0.8),

                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        THelperFunctions.isDarkMode(context)
                            ? Colors.black.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Spacer(),
            // App name/title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade900.withOpacity(0.8),

                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),

                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'DATRIDE',
                style: TextStyle(
                  color:
                      THelperFunctions.isDarkMode(context)
                          ? Colors.purple
                          : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Spacer(),
            // Settings button
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade900.withOpacity(0.8),

                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        THelperFunctions.isDarkMode(context)
                            ? Colors.black.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  // Navigate to settings
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationButton() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.my_location, color: Colors.purple),
          onPressed: () => _controller.goToCurrentLocation(),
        ),
      ),
    );
  }

  Widget _buildSlidingPanel(ScrollController scrollController) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Promo Discount Section
            _buildPromoDiscountSection(),
            const SizedBox(height: 20),
            // Drag handle with purple accent
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
            // Title with purple gradient
            ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    colors: [
                      Colors.purple.shade300,
                      Colors.deepPurple.shade500,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
              child: const Text(
                'Book a Ride',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // "Where to?" search field with purple accents
            _buildDestinationSearchField(),
            const SizedBox(height: 25),
            // Saved places
            _buildSavedPlaces(),
            const SizedBox(height: 25),
            // Recent locations
            _buildRecentLocations(scrollController),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoDiscountSection() {
    return Container(
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
                  'Enjoy 20% off your ride today. No code needed!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
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
            ),
            child: const Text('Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationSearchField() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LocationSearchScreen()),
        );

        if (result != null) {
          _controller.updateRouteWithSearchResult(result);
          setState(() {});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: LinearGradient(
            colors: [Colors.grey.shade800, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search, color: Colors.purple, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Where to?',
              style: TextStyle(color: Colors.grey.shade300, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune, color: Colors.purple, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPlaces() {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved Places',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Add a subtle purple underline
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade300, Colors.deepPurple.shade500],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildSavedPlaceItem(
              icon: Icons.home,
              title: 'Home',
              address: '123 Main St',
              color: Colors.purple.shade300,
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.deepPurple.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                _controller.selectSavedPlace('home');
              },
            ),
            const SizedBox(width: 15),
            _buildSavedPlaceItem(
              icon: Icons.work,
              title: 'Work',
              address: '456 Office Ave',
              color: Colors.deepPurple.shade300,
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade300, Colors.purple.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                _controller.selectSavedPlace('work');
              },
            ),
            const SizedBox(width: 15),
            _buildSavedPlaceItem(
              icon: Icons.add,
              title: 'Add',
              address: 'New Place',
              color: Colors.purpleAccent.shade200,
              gradient: LinearGradient(
                colors: [
                  Colors.purpleAccent.shade100,
                  Colors.purpleAccent.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                // Navigate to add new place screen
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSavedPlaceItem({
    required IconData icon,
    required String title,
    required String address,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color:
                    isDarkMode
                        // ignore: deprecated_member_use
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: TextStyle(
                  color:
                      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentLocations(ScrollController scrollController) {
    final recentLocations = _controller.recentLocations;
    final isDarkMode = THelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Places',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // View all recent places
              },
              style: TextButton.styleFrom(foregroundColor: Colors.purple),
              child: Text('View All', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 15),
        // Wrap ListView.builder in a constrained container
        SizedBox(
          height: 200, // Set a fixed height to avoid layout issues
          child: ListView.builder(
            controller: scrollController,
            itemCount: recentLocations.length,
            itemBuilder: (context, index) {
              final location = recentLocations[index];
              return _buildRecentLocationItem(
                placeName: location['name'] ?? 'Unknown place',
                address: location['address'] ?? 'Unknown address',
                timeAgo: location['timeAgo'] ?? 'Unknown time',
                onTap: () {
                  _controller.selectRecentLocation(index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentLocationItem({
    required String placeName,
    required String address,
    required String timeAgo,
    required VoidCallback onTap,
  }) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color:
                  isDarkMode
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade300, Colors.deepPurple.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    placeName,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: TextStyle(
                      color:
                          isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                timeAgo,
                style: TextStyle(color: Colors.purple.shade200, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
