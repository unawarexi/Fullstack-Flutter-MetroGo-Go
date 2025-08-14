import 'package:datride_mobile/core/maps/book_ride_map.dart';
import 'package:datride_mobile/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:datride_mobile/screens/book_ride/item_form.dart';

class BookRideOptions extends StatefulWidget {
  final String purpose;

  const BookRideOptions({super.key, required this.purpose});

  @override
  State<BookRideOptions> createState() => _BookRideOptionsState();
}

class _BookRideOptionsState extends State<BookRideOptions> {
  // Transport options data (keep the existing structure)
  final Map<String, List<Map<String, dynamic>>> transportOptions = {
    // Transport options for each purpose with images and details
    'People': [
      {
        'name': 'Cars',
        'image': TImages.car,
        'services': ['Standard', 'Premium', 'XL', 'DatSave'],
        'vehicles': [
          {
            'name': 'Sedan',
            'image': TImages.sedan,
            'price': 'From \$10',
            'capacity': '4 passengers',
            'details': 'Comfortable city ride',
            'tag': 'Standard',
          },
          {
            'name': 'SUV',
            'image': TImages.suv,
            'price': 'From \$15',
            'capacity': '6 passengers',
            'details': 'Spacious group travel',
            'tag': 'XL',
          },
          {
            'name': 'Minivan',
            'image': TImages.minivan,
            'price': 'From \$20',
            'capacity': '7 passengers',
            'details': 'Ideal for family trips',
            'tag': 'XL',
          },
          {
            'name': 'Party Bus',
            'image': TImages.grouptrip,
            'price': 'From \$50',
            'capacity': '20 passengers',
            'details': 'Luxury group experience',
            'tag': 'DatSave',
          },
          {
            'name': 'Pickup Truck',
            'image': TImages.truck,
            'price': 'From \$25',
            'capacity': 'Medium load',
            'details': 'Great for moving',
            'tag': 'XL',
          },
          {
            'name': 'Luxury Sedan',
            'image': TImages.lux,
            'price': 'From \$50',
            'capacity': '4 passengers',
            'details': 'Premium comfort and style',
            'tag': 'Premium',
          },
        ],
      },
      {
        'name': 'Emergency',
        'image': TImages.emergency,
        'services': ['police', 'ambulance', 'fire service'],
        'vehicles': [
          {
            'name': 'Health Care',
            'image': TImages.ambulance,
            'price': 'From \$50',
            'capacity': '4 passengers',
            'details': 'Premium comfort and style',
          },
          {
            'name': 'Police Department',
            'image': TImages.police,
            'price': 'From \$50',
            'capacity': '4 passengers',
            'details': 'Premium comfort and style',
          },
          {
            'name': 'Fire Department',
            'image': TImages.fire,
            'price': 'From \$50',
            'capacity': '4 passengers',
            'details': 'Premium comfort and style',
          },
          {
            'name': 'Animal Services',
            'image': TImages.vet,
            'price': 'From \$50',
            'capacity': '4 passengers',
            'details': 'Premium comfort and style',
          },
          {
            'name': 'Environmental Services',
            'image': TImages.airlift,
            'price': 'From \$50',
            'capacity': '4 passengers',
            'details': 'Premium comfort and style',
          },
        ],
      },
    ],

    // items
    'Items': [
      {
        'name': 'Cars',
        'image': TImages.car,
        'services': ['Express', 'Standard', 'Economy'],
        'details': [
          {
            'price': 'From \$30',
            'capacity': 'Up to 200kg',
            'purpose': 'Efficient delivery for medium-sized goods',
          },
        ],
      },
      {
        'name': 'Bike Courier',
        'image': TImages.bike,
        'services': ['Express', 'Standard', 'Economy'],
        'details': [
          {
            'price': 'From \$10',
            'capacity': 'Up to 20kg',
            'purpose': 'Quick and eco-friendly delivery for small packages',
          },
        ],
      },
      {
        'name': 'Drone Courier',
        'image': TImages.drone,
        'services': ['Express', 'Standard', 'Economy'],
        'details': [
          {
            'price': 'From \$40',
            'capacity': 'Up to 5kg',
            'purpose': 'Fast and innovative delivery for lightweight items',
          },
        ],
      },
      {
        'name': 'Cargo Van',
        'image': TImages.van,
        'services': ['Express', 'Standard', 'Economy'],
        'details': [
          {
            'price': 'From \$50',
            'capacity': 'Up to 1000kg',
            'purpose': 'Ideal for transporting large and heavy goods',
          },
        ],
      },
      {
        'name': 'Trucking courier',
        'image': TImages.truck,
        'services': ['Express', 'Standard', 'Economy'],
        'details': [
          {
            'price': 'From \$50',
            'capacity': 'Up to 1000kg',
            'purpose': 'Ideal for transporting large and heavy goods',
          },
        ],
      },
      {
        'name': 'Autonomous Robots',
        'image': TImages.robot,
        'services': ['Express', 'Standard', 'Economy'],
        'details': [
          {
            'price': 'From \$25',
            'capacity': 'Up to 50kg',
            'purpose':
                'Reliable and automated delivery for small to medium items',
          },
        ],
      },
      {
        'name': 'Air Freights',
        'image': TImages.airplane,
        'services': ['Express', 'Standard', 'Economy'],
        'details': [
          {
            'price': 'From \$200',
            'capacity': 'Up to 5000kg',
            'purpose': 'Fast international shipping for large cargo',
          },
        ],
      },
      {
        'name': 'Ship Consignments',
        'image': TImages.cargoship,
        'services': ['Express', 'Standard', 'Economy'],
        'details': [
          {
            'price': 'From \$500',
            'capacity': 'Unlimited',
            'purpose': 'Cost-effective bulk shipping for international trade',
          },
        ],
      },
    ],
    'Others': [
      {
        'name': 'Corporate Events',
        'image':  TImages.work,
        'description': 'Transportation services for corporate events',
        'color': Colors.blue,
      },
      {
        'name': 'Wedding Transport',
        'image':  TImages.love, // Updated to a more fitting icon
        'description': 'Luxury vehicles for your special day',
        'color': Colors.pink,
      },
      {
        'name': 'Private Jets',
        'image': TImages.jet,
        'description': 'Reliable rides to and from the airport',
        'color': Colors.amber,
      },
      {
        'name': 'InterState',
        'image':  TImages.road, // Updated to a more fitting icon
        'description': 'Comfortable rides for longer journeys',
        'color': Colors.green,
      },
      {
        'name': 'Chauffeur Service',
        'image':  TImages.car, // Updated to a more fitting icon
        'description': 'Professional chauffeurs for any occasion',
        'color': Colors.deepPurple,
      },
  
      {
        'name': 'Boat Cruise',
        'image': TImages.yatcht,
        'description': 'Luxury yachting experiences for leisure',
        'color': Colors.cyan,
      },
      {
        'name': 'JetPack Joyrides',
        'image': TImages.jetpack,
        'description': 'Luxury yachting experiences for leisure',
        'color': Colors.cyan,
      },
  
      {
        'name': 'City Tours',
        'image': TImages.evac,
        'description': 'Explore the city with guided tours',
        'color': Colors.teal,
      },
      {
        'name': 'Adventure Rides',
        'image': TImages.jetski,
        'description': 'Thrilling rides for adventure seekers',
        'color': Colors.redAccent,
      },
    ],
  };

  // State variables for selection
  Map<String, dynamic>? _selectedOption;
  Map<String, dynamic>? _selectedVehicle;
  String? _selectedService;

  Future<void> _refreshData() async {
    // Simulate a network call or data refresh
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // Update the transportOptions or any other state variables if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    final options = transportOptions[widget.purpose] ?? [];

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDarkMode),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: _buildOptionsGrid(options, isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Book Your ${widget.purpose} Ride',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(
    List<Map<String, dynamic>> options,
    bool isDarkMode,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        return _buildOptionCard(options[index], isDarkMode);
      },
    );
  }

  Widget _buildOptionCard(Map<String, dynamic> option, bool isDarkMode) {
    return GestureDetector(
      onTap: () => _showEnhancedBottomSheet(context, option, isDarkMode),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(option['image']),
                  fit: BoxFit.contain,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            option['name'],
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showEnhancedBottomSheet(
    BuildContext context,
    Map<String, dynamic> option,
    bool isDarkMode,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  maxChildSize: 0.95,
                  minChildSize: 0.6,
                  builder:
                      (_, controller) => Container(
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? Colors.grey.shade900 : Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: _buildBottomSheetContent(
                          context,
                          option,
                          isDarkMode,
                          controller,
                          setModalState,
                        ),
                      ),
                ),
          ),
    );
  }

  Widget _buildBottomSheetContent(
    BuildContext context,
    Map<String, dynamic> option,
    bool isDarkMode,
    ScrollController controller,
    StateSetter setModalState,
  ) {
    // Handle 'Others' purpose separately
    if (widget.purpose == 'Others') {
      return _buildOthersContent(context, option, isDarkMode, controller);
    }

    // Main content for People and Items purposes
    return Column(
      children: [
        // Drag handle
        _buildDragHandle(),

        // Title
        _buildBottomSheetTitle(option, isDarkMode),

        // Services selection (if applicable)
        if (option['services'] != null)
          _buildServicesSelection(option, isDarkMode, setModalState),

        // Vehicles or Details content
        Expanded(
          child: _buildVehiclesOrDetailsContent(
            context,
            option,
            isDarkMode,
            controller,
            setModalState,
          ),
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 50,
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.purple.shade700,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildBottomSheetTitle(Map<String, dynamic> option, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        '${option['name']} Services',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildServicesSelection(
    Map<String, dynamic> option,
    bool isDarkMode,
    StateSetter setModalState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              option['services'].map<Widget>((service) {
                final isSelected = _selectedService == service;
                return GestureDetector(
                  onTap: () {
                    setModalState(() {
                      _selectedService = service;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.purple.shade700
                              : (isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.purple.shade700
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      service,
                      style: TextStyle(
                        color:
                            isSelected
                                ? Colors.white
                                : (isDarkMode
                                    ? Colors.white70
                                    : Colors.black87),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildVehiclesOrDetailsContent(
    BuildContext context,
    Map<String, dynamic> option,
    bool isDarkMode,
    ScrollController controller,
    StateSetter setModalState,
  ) {
    final items =
        widget.purpose == 'Items' ? option['details'] : option['vehicles'];

    return ListView.separated(
      controller: controller,
      itemCount: items.length,
      separatorBuilder:
          (context, index) => Divider(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            indent: 20,
            endIndent: 20,
          ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildVehicleOrDetailTile(
          context,
          option,
          item,
          isDarkMode,
          setModalState,
        );
      },
    );
  }

  Widget _buildVehicleOrDetailTile(
    BuildContext context,
    Map<String, dynamic> option,
    Map<String, dynamic> item,
    bool isDarkMode,
    StateSetter setModalState,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading:
          widget.purpose != 'Items'
              ? Image.asset(
                item['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
              : null,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.purpose == 'Items' ? 'Price: ${item['price']}' : item['name'],
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (item['tag'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.shade700,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                item['tag'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.purpose == 'Items'
                ? 'Capacity: ${item['capacity']}'
                : item['details'],
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          if (widget.purpose == 'Items')
            Text(
              'Purpose: ${item['purpose']}',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          if (widget.purpose != 'Items')
            Text(
              item['capacity'],
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
        ],
      ),
      trailing: Text(
        widget.purpose == 'Items' ? '' : item['price'],
        style: TextStyle(
          color: Colors.purple.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () => _handleItemSelection(context, option, item, isDarkMode),
    );
  }

  void _handleItemSelection(
    BuildContext context,
    Map<String, dynamic> option,
    Map<String, dynamic> item,
    bool isDarkMode,
  ) {
    setState(() {
      _selectedOption = option;
      _selectedVehicle = item;
    });

    Navigator.pop(context);

    if (widget.purpose == 'Items') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ItemForm()),
      );
    } else {
      _showBookingConfirmation(context, isDarkMode);
    }
  }

  Widget _buildOthersContent(
    BuildContext context,
    Map<String, dynamic> option,
    bool isDarkMode,
    ScrollController controller,
  ) {
    return Column(
      children: [
        _buildDragHandle(),
        _buildBottomSheetTitle(option, isDarkMode),
        Expanded(
          child: ListView.separated(
            controller: controller,
            itemCount: transportOptions['Others']?.length ?? 0,
            separatorBuilder:
                (context, index) => Divider(
                  color:
                      isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  indent: 20,
                  endIndent: 20,
                ),
            itemBuilder: (context, index) {
              final otherOption = transportOptions['Others']?[index];
              if (otherOption == null) return const SizedBox.shrink();

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                leading: CircleAvatar(
                  backgroundColor: otherOption['color'],
                  backgroundImage: AssetImage(otherOption['image']),
                ),
                title: Text(
                  otherOption['name'],
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  otherOption['description'],
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedOption = otherOption;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${otherOption['name']} selected!'),
                      backgroundColor: Colors.purple.shade700,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showBookingConfirmation(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Confirm Booking',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehicle: ${_selectedVehicle?['name']}',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                Text(
                  'Price: ${_selectedVehicle?['price']}',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => BookRideMap()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                ),
                child: const Text('Book Now'),
              ),
            ],
          ),
    );
  }
}
