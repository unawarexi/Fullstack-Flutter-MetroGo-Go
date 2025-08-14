import 'package:datride_mobile/screens/place/place_details.dart';
import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'places_controller.dart';


class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _categoriesScrollController = ScrollController();

  // List of categories with their icon and label
  final List<Map<String, dynamic>> categories = [
    {'id': 'restaurant', 'icon': Icons.restaurant, 'label': 'Restaurants'},
    {'id': 'tourist_attraction', 'icon': Icons.attractions, 'label': 'Attractions'},
    {'id': 'park', 'icon': Icons.park, 'label': 'Parks'},
    {'id': 'cafe', 'icon': Icons.local_cafe, 'label': 'Cafes'},
    {'id': 'bar', 'icon': Icons.local_bar, 'label': 'Bars'},
    {'id': 'shopping_mall', 'icon': Icons.shopping_bag, 'label': 'Shopping'},
    {'id': 'hotel', 'icon': Icons.hotel, 'label': 'Hotels'},
    {'id': 'movie_theater', 'icon': Icons.movie, 'label': 'Cinemas'},
    {'id': 'gym', 'icon': Icons.fitness_center, 'label': 'Gyms'},
    {'id': 'museum', 'icon': Icons.museum, 'label': 'Museums'},
    {'id': 'night_club', 'icon': Icons.nightlife, 'label': 'Nightlife'},
    {'id': 'art_gallery', 'icon': Icons.palette, 'label': 'Art Galleries'},
    {'id': 'mechanic', 'icon': Icons.build, 'label': 'Mechanics'},
    {'id': 'hospital', 'icon': Icons.local_hospital, 'label': 'Hospitals'},
    {'id': 'airport', 'icon': Icons.local_airport, 'label': 'Airports'},
    {'id': 'train_station', 'icon': Icons.train, 'label': 'Train Stations'},
    {'id': 'bus_station', 'icon': Icons.directions_bus, 'label': 'Bus Stations'},
    {'id': 'pharmacy', 'icon': Icons.local_pharmacy, 'label': 'Pharmacies'},
    {'id': 'school', 'icon': Icons.school, 'label': 'Schools'},
    {'id': 'university', 'icon': Icons.account_balance, 'label': 'Universities'},
    {'id': 'library', 'icon': Icons.local_library, 'label': 'Libraries'},
    {'id': 'bank', 'icon': Icons.account_balance_wallet, 'label': 'Banks'},
    {'id': 'atm', 'icon': Icons.atm, 'label': 'ATMs'},
    {'id': 'gas_station', 'icon': Icons.local_gas_station, 'label': 'Gas Stations'},
    {'id': 'car_rental', 'icon': Icons.directions_car, 'label': 'Car Rentals'},
    {'id': 'car_wash', 'icon': Icons.local_car_wash, 'label': 'Car Wash'},
    {'id': 'supermarket', 'icon': Icons.shopping_cart, 'label': 'Supermarkets'},
    {'id': 'bakery', 'icon': Icons.cake, 'label': 'Bakeries'},
    {'id': 'butcher', 'icon': Icons.restaurant_menu, 'label': 'Butchers'},
    {'id': 'hardware_store', 'icon': Icons.construction, 'label': 'Hardware Stores'},
    {'id': 'electronics_store', 'icon': Icons.electrical_services, 'label': 'Electronics Stores'},
    {'id': 'furniture_store', 'icon': Icons.chair, 'label': 'Furniture Stores'},
    {'id': 'pet_store', 'icon': Icons.pets, 'label': 'Pet Stores'},
    {'id': 'veterinary_clinic', 'icon': Icons.local_hospital, 'label': 'Veterinary Clinics'},
    {'id': 'hair_care', 'icon': Icons.content_cut, 'label': 'Hair Salons'},
    {'id': 'beauty_salon', 'icon': Icons.brush, 'label': 'Beauty Salons'},
    {'id': 'spa', 'icon': Icons.spa, 'label': 'Spas'},
    {'id': 'laundry', 'icon': Icons.local_laundry_service, 'label': 'Laundries'},
    {'id': 'post_office', 'icon': Icons.local_post_office, 'label': 'Post Offices'},
    {'id': 'police_station', 'icon': Icons.local_police, 'label': 'Police Stations'},
    {'id': 'fire_station', 'icon': Icons.local_fire_department, 'label': 'Fire Stations'},
    {'id': 'stadium', 'icon': Icons.sports_soccer, 'label': 'Stadiums'},
    {'id': 'zoo', 'icon': Icons.pets, 'label': 'Zoos'},
    {'id': 'aquarium', 'icon': Icons.water, 'label': 'Aquariums'},
    {'id': 'amusement_park', 'icon': Icons.park, 'label': 'Amusement Parks'},
    {'id': 'casino', 'icon': Icons.casino, 'label': 'Casinos'},
    {'id': 'church', 'icon': Icons.church, 'label': 'Churches'},
    {'id': 'mosque', 'icon': Icons.mosque, 'label': 'Mosques'},
    {'id': 'temple', 'icon': Icons.temple_hindu, 'label': 'Temples'},
    {'id': 'synagogue', 'icon': Icons.synagogue, 'label': 'Synagogues'},
    {'id': 'cemetery', 'icon': Icons.grass, 'label': 'Cemeteries'},
    {'id': 'courthouse', 'icon': Icons.gavel, 'label': 'Courthouses'},
    {'id': 'embassy', 'icon': Icons.flag, 'label': 'Embassies'},
    {'id': 'government_office', 'icon': Icons.account_balance, 'label': 'Govt Offices'},
    {'id': 'recycling_center', 'icon': Icons.recycling, 'label': 'Recycling Centers'},
    {'id': 'parking', 'icon': Icons.local_parking, 'label': 'Parking'},
    {'id': 'beach', 'icon': Icons.beach_access, 'label': 'Beaches'},
    {'id': 'campground', 'icon': Icons.nature_people, 'label': 'Campgrounds'},
    {'id': 'hiking_trail', 'icon': Icons.terrain, 'label': 'Hiking Trails'},
    {'id': 'waterfall', 'icon': Icons.waterfall_chart, 'label': 'Waterfalls'},
    {'id': 'lake', 'icon': Icons.water, 'label': 'Lakes'},
    {'id': 'mountain', 'icon': Icons.landscape, 'label': 'Mountains'},
  ];

  @override
  void initState() {
    super.initState();
    // Fetch current location when the screen loads
    Future.microtask(() {
      ref.read(placesControllerProvider.notifier).getUserLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoriesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(placesControllerProvider);
    final selectedCategory = controller.selectedCategory;
    final isDarkMode = THelperFunctions.isDarkMode(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode ? [Colors.black, Colors.grey.shade800] : [Colors.white, Colors.grey.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar with Search
              _buildSearchBar(isDarkMode),
              
              SizedBox(height: 20,),
              // Categories Horizontal Scroll
              _buildCategoriesScroll(selectedCategory),

               SizedBox(height: 20,),
              
              // Divider
              Divider(color: Colors.grey.shade700, height: 1),
              
              // Loading indicator
              if (controller.isLoading) 
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator(color: Colors.purple)),
                ),
                
              // Main Content - Places
              if (!controller.isLoading)
                Expanded(
                  child: _buildPlacesContent(controller),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Explore Places',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.gps_fixed, color: isDarkMode ? Colors.purple : Colors.black),
                onPressed: () {
                  ref.read(placesControllerProvider.notifier).getUserLocation();
                },
                tooltip: 'Get nearby places',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              onSubmitted: (value) {
                ref.read(placesControllerProvider.notifier).searchPlaces(value);
              },
              decoration: InputDecoration(
                hintText: "Search for places",
                hintStyle: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.purple : Colors.black),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                  onPressed: () {
                    _searchController.clear();
                    // Clear search results
                    ref.read(placesControllerProvider.notifier).clearSearch();
                  },
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesScroll(String? selectedCategory) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return SizedBox( // Added SizedBox to constrain height
      height: 80, // Reduced height
      child: ListView.builder(
        controller: _categoriesScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category['id'] == selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                ref.read(placesControllerProvider.notifier).filterPlacesByCategory(category['id']);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50, // Reduced size
                    height: 50, // Reduced size
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.purple
                          : isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.purple
                            : isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade500,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      category['icon'],
                      color: isSelected
                          ? Colors.white
                          : isDarkMode
                              ? Colors.grey.shade300
                              : Colors.purple,
                      size: 24, // Reduced size
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['label'],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.purple
                          : isDarkMode
                              ? Colors.grey.shade300
                              : Colors.black,
                      fontSize: 10, // Reduced size
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlacesContent(PlacesController controller) {
    // If search results exist, display them
    if (controller.searchResults.isNotEmpty) {
      return _buildPlacesList(
        controller.searchResults,
        title: controller.selectedCategory != null
            ? 'Results for ${_getCategoryLabel(controller.selectedCategory!)}'
            : 'Search Results',
      );
    }
    
    // If no search but nearby places exist
    if (controller.nearbyPlaces.isNotEmpty) {
      return _buildPlacesList(
        controller.nearbyPlaces,
        title: 'Places Near You',
      );
    }
    final isDarkMode = THelperFunctions.isDarkMode(context);
    // No results state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 80, color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No places found',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or category',
            style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesList(List<dynamic> places, {required String title}) {
    // final isDarkMode = THelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return _buildPlaceCard(place);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceCard(dynamic place) {
    final placeName = place['name'] ?? "Unknown Place";
    final placeAddress = place['vicinity'] ?? "Unknown Address";
    final placeRating = place['rating']?.toString() ?? "N/A";
    final placeImage = place['photos'] != null
        ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place['photos'][0]['photo_reference']}&key=AIzaSyBoWy2-vzkQzOw9FrCKUyfxWpa5_dsPi10'
        : null;
    
    // Get place types for tags
    final List<String> placeTypes = place['types'] != null 
        ? List<String>.from(place['types'])
        : [];

        final isDarkMode = THelperFunctions.isDarkMode(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceDetailsScreen(placeId: place['place_id']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Place image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: placeImage != null
                    ? Image.network(
                        placeImage,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade900,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.purple,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade900,
                          child: Icon(Icons.image_not_supported, color: Colors.grey.shade600, size: 50),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade900,
                        child: Icon(Icons.place, color: Colors.grey.shade600, size: 50),
                      ),
              ),
            ),
            
            // Place info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          placeName,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              placeRating,
                              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          placeAddress,
                          style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Tags for place types
                  if (placeTypes.isNotEmpty)
                    SizedBox(
                      height: 24,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: placeTypes.length > 3 ? 3 : placeTypes.length,
                        itemBuilder: (context, index) {
                          final type = placeTypes[index].replaceAll('_', ' ');
                          return Container(
                            margin: EdgeInsets.only(right: 8),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.purple.withOpacity(0.3)),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(color: isDarkMode ? Colors.grey.shade300 : Colors.black54, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(String categoryId) {
    final category = categories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => {'label': 'Places'},
    );
    return category['label'];
  }
}