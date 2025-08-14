import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'places_controller.dart';

class PlaceDetailsScreen extends ConsumerStatefulWidget {
  final String placeId;

  const PlaceDetailsScreen({super.key, required this.placeId});

  @override
  ConsumerState<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends ConsumerState<PlaceDetailsScreen> {
  Map<String, dynamic>? placeDetails;
  bool isLoading = true;
  int selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPlaceDetails();
  }

  Future<void> _loadPlaceDetails() async {
    try {
      final details = await ref.read(placesControllerProvider.notifier).getPlaceDetails(widget.placeId);
      setState(() {
        placeDetails = details;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
     if(mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load place details')),
      );
     }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.grey.shade900],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.grey.shade300],
                ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.purple))
              : placeDetails == null
                  ? _buildErrorView(isDarkMode)
                  : _buildDetailsView(isDarkMode),
        ),
      ),
    );
  }

  Widget _buildErrorView(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade800),
          const SizedBox(height: 16),
          Text(
            'Failed to load place details',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsView(bool isDarkMode) {
    final name = placeDetails!['name'] ?? 'Unknown Place';
    final address = placeDetails!['formatted_address'] ?? placeDetails!['vicinity'] ?? 'No address available';
    final rating = placeDetails!['rating']?.toString() ?? 'N/A';
    final photos = placeDetails!['photos'] as List<dynamic>?;
    final phoneNumber = placeDetails!['formatted_phone_number'];
    final website = placeDetails!['website'];
    final openingHours = placeDetails!['opening_hours'];
    final reviews = placeDetails!['reviews'] as List<dynamic>?;
    final types = placeDetails!['types'] as List<dynamic>? ?? [];
    
    // Price level representation
    final priceLevel = placeDetails!['price_level'] != null 
      ? List.filled(placeDetails!['price_level'], '\$').join() 
      : null;
    
    return CustomScrollView(
      slivers: [
        // App Bar with Image Carousel
        SliverAppBar(
          expandedHeight: MediaQuery.of(context).size.height * 0.35, // Adjust height to cover safe area
          pinned: true,
          backgroundColor: isDarkMode ? Colors.black : Colors.grey.shade800,
          leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: photos != null && photos.isNotEmpty
                ? _buildImageCarousel(photos)
                : Container(
                    color: Colors.grey.shade800,
                    child: Center(
                      child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey.shade600),
                    ),
                  ),
          ),
        ),
        
        // Details Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text(
                            rating,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black, // Updated text color
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Price level if available
                if (priceLevel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      priceLevel,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                
                // Categories/Types
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: types.take(5).map<Widget>((type) {
                    final typeName = type.toString().replaceAll('_', ' ');
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.purple.withOpacity(0.3)),
                      ),
                      child: Text(
                        typeName,
                        style: TextStyle(color: isDarkMode ? Colors.grey.shade300 : Colors.black54, fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
                
                // Address
                SizedBox(height: 24),
                _buildInfoRow(Icons.location_on, address),
                
                // Phone number
                if (phoneNumber != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildActionRow(
                      Icons.phone,
                      phoneNumber,
                      () async {
                        final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    ),
                  ),
                
                // Website
                if (website != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildActionRow(
                      Icons.public,
                      website,
                      () async {
                        final Uri uri = Uri.parse(website);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    ),
                  ),
                
                // Opening hours
                if (openingHours != null && openingHours['weekday_text'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: _buildOpeningHours(openingHours),
                  ),
                
                // Directions button
                SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    _launchMaps();
                  },
                  icon: Icon(Icons.directions),
                  label: Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                
                // Reviews section
                if (reviews != null && reviews.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: _buildReviewsSection(reviews),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(List<dynamic> photos) {
    // final isDarkMode = THelperFunctions.isDarkMode(context);
    return Stack(
      children: [
        // PageView for swiping through images
        PageView.builder(
          itemCount: photos.length,
          onPageChanged: (index) {
            setState(() {
              selectedImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final photoReference = photos[index]['photo_reference'];
            final photoUrl = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=$photoReference&key=AIzaSyBoWy2-vzkQzOw9FrCKUyfxWpa5_dsPi10';
            
            return Image.network(
              photoUrl,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.black,
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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade800,
                  child: Center(
                    child: Icon(Icons.broken_image, size: 80, color: Colors.grey.shade600),
                  ),
                );
              },
            );
          },
        ),
        
        // Image count indicator
        if (photos.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${selectedImageIndex + 1}/${photos.length}',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
        // Gradient overlay for better visibility of back button
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade800,
          size: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.purple,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpeningHours(Map<String, dynamic> openingHours) {
    final weekdayText = openingHours['weekday_text'] as List<dynamic>?;
    final isOpenNow = openingHours['open_now'] ?? false;
    final isDarkMode = THelperFunctions.isDarkMode(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Opening Hours',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isOpenNow ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isOpenNow ? 'Open Now' : 'Closed',
                style: TextStyle(
                  color: isOpenNow ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        if (weekdayText != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: weekdayText.map<Widget>((day) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade300 : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewsSection(List<dynamic> reviews) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        // Display up to 3 reviews
        ...reviews.take(3).map<Widget>((review) {
          final authorName = review['author_name'] ?? 'Anonymous';
          final authorPhoto = review['profile_photo_url'];
          final rating = review['rating'] ?? 0;
          final timeDescription = review['relative_time_description'] ?? '';
          final text = review['text'] ?? 'No review text';
          
          return Container(
            margin: EdgeInsets.only(bottom: 20),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade700, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author info and rating
                Row(
                  children: [
                    // Author photo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade700,
                        image: authorPhoto != null
                            ? DecorationImage(
                                image: NetworkImage(authorPhoto),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: authorPhoto == null
                          ? Center(
                              child: Text(
                                authorName.isNotEmpty ? authorName[0].toUpperCase() : 'A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 12),
                    // Author name and time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authorName,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            timeDescription,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rating
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
                // Review text
                SizedBox(height: 12),
                Text(
                  text,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey.shade300 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }),
        
        // Show all reviews button if there are more than 3
        if (reviews.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton(
              onPressed: () {
                // Show dialog with all reviews
                _showAllReviews(reviews);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'View All ${reviews.length} Reviews',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  void _showAllReviews(List<dynamic> reviews) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        'All Reviews',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: isDarkMode ? Colors.white : Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey.shade800),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      final authorName = review['author_name'] ?? 'Anonymous';
                      final authorPhoto = review['profile_photo_url'];
                      final rating = review['rating'] ?? 0;
                      final timeDescription = review['relative_time_description'] ?? '';
                      final text = review['text'] ?? 'No review text';
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade700, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade700,
                                    image: authorPhoto != null
                                        ? DecorationImage(
                                            image: NetworkImage(authorPhoto),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: authorPhoto == null
                                      ? Center(
                                          child: Text(
                                            authorName.isNotEmpty ? authorName[0].toUpperCase() : 'A',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        authorName,
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        timeDescription,
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < rating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              text,
                              style: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _launchMaps() async {
    if (placeDetails == null || placeDetails!['geometry'] == null) return;
    
    final lat = placeDetails!['geometry']['location']['lat'];
    final lng = placeDetails!['geometry']['location']['lng'];
    // final name = Uri.encodeComponent(placeDetails!['name'] ?? ''); 
    
    // Try to launch Google Maps app first
    final Uri googleMapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=${widget.placeId}&travelmode=driving'
    );
    
    try {
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web URL
        final Uri webMapsUri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=${widget.placeId}'
        );
        await launchUrl(webMapsUri);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch maps')),
      );
    }
  }
}