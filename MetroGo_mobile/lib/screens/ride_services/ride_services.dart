import 'package:datride_mobile/screens/ride_services/extra_services.dart';
import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;


class RideServices extends StatefulWidget {
  const RideServices({super.key});

  @override
  State<RideServices> createState() => _RideServicesState();
}

class _RideServicesState extends State<RideServices> with TickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 5, vsync: this); // Updated length to 5
  late AnimationController _animController;
  int _selectedService = -1;
  int _currentTabIndex = 0;
  
  final List<String> _tabTitles = ['Normal', 'Emergency', 'Advanced', 'Group', 'Extra']; // Added "Extra"
  
  // Normal ride services
  final List<Map<String, dynamic>> _normalServices = [
    {
      'title': 'Standard Ride',
      'icon': Icons.directions_car,
      'description': 'Affordable everyday rides for up to 4 passengers',
      'price': 'From \$5.99',
      'time': '3-5 min'
    },
    {
      'title': 'Premium',
      'icon': Icons.airline_seat_individual_suite,
      'description': 'High-end vehicles with top-rated drivers',
      'price': 'From \$12.99',
      'time': '5-8 min'
    },
    {
      'title': 'XL Ride',
      'icon': Icons.airport_shuttle,
      'description': 'Spacious vehicles for up to 6 passengers',
      'price': 'From \$8.99',
      'time': '4-7 min'
    },
    {
      'title': 'DatSave',
      'icon': Icons.savings,
      'description': 'Share your ride and save on your commute',
      'price': 'From \$3.99',
      'time': '7-10 min'
    },
  ];
  
  // Emergency services
  final List<Map<String, dynamic>> _emergencyServices = [
    {
      'title': 'Medical',
      'icon': Icons.local_hospital,
      'description': 'Emergency ambulance with medical professionals',
      'price': 'Priority Service',
      'time': '2-4 min'
    },
    {
      'title': 'Fire Service',
      'icon': Icons.local_fire_department,
      'description': 'Rapid response fire brigade',
      'price': 'Priority Service',
      'time': '3-5 min'
    },
    {
      'title': 'Police',
      'icon': Icons.local_police,
      'description': 'Law enforcement assistance for emergencies',
      'price': 'Priority Service',
      'time': '2-5 min'
    },
    {
      'title': 'Air Evacuation',
      'icon': Icons.airplanemode_active,
      'description': 'Emergency helicopter evacuation service',
      'price': 'Priority Service',
      'time': '8-12 min'
    },
  ];
  
  // Advanced luxury services
  final List<Map<String, dynamic>> _advancedServices = [
    {
      'title': 'Luxury Jet',
      'icon': Icons.flight,
      'description': 'Private jet services for long-distance travel',
      'price': 'From \$999',
      'time': 'On demand'
    },
    {
      'title': 'Helicopter',
      'icon': Icons.airplanemode_active,
      'description': 'Premium helicopter rides with panoramic views',
      'price': 'From \$499',
      'time': '30-60 min'
    },
    {
      'title': 'Drone Delivery',
      'icon': Icons.delivery_dining,
      'description': 'Fast delivery via automated drones',
      'price': 'From \$29.99',
      'time': '10-20 min'
    },
    {
      'title': 'Robot Courier',
      'icon': Icons.smart_toy,
      'description': 'Autonomous robot delivery for packages',
      'price': 'From \$19.99',
      'time': '15-25 min'
    },
    {
      'title': 'Yacht Charter',
      'icon': Icons.sailing,
      'description': 'Luxury yacht experiences with full crew',
      'price': 'From \$599',
      'time': 'Schedule'
    },
    {
      'title': 'Jetski Rental',
      'icon': Icons.waves,
      'description': 'Exciting water adventure with premium jetskis',
      'price': 'From \$79.99',
      'time': '15-30 min'
    },
  ];
  
  // Group services
  final List<Map<String, dynamic>> _groupServices = [
    {
      'title': 'Party Bus',
      'icon': Icons.celebration,
      'description': 'Luxury party bus for special occasions',
      'price': 'From \$199',
      'time': 'Schedule'
    },
    {
      'title': 'Group Van',
      'icon': Icons.groups,
      'description': 'Comfortable van for up to 12 passengers',
      'price': 'From \$29.99',
      'time': '10-15 min'
    },
    {
      'title': 'Tour Bus',
      'icon': Icons.tour,
      'description': 'Guided city tours with professional drivers',
      'price': 'From \$149',
      'time': 'Schedule'
    },
    {
      'title': 'Group Shuttle',
      'icon': Icons.airport_shuttle,
      'description': 'Airport or event shuttle services for groups',
      'price': 'From \$49.99',
      'time': 'Schedule'
    },
  ];

  List<Map<String, dynamic>> get _currentServices {
    switch (_currentTabIndex) {
      case 0:
        return _normalServices;
      case 1:
        return _emergencyServices;
      case 2:
        return _advancedServices;
      case 3:
        return _groupServices;
      default:
        return _normalServices;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController.addListener(_handleTabChange);
    
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedService = -1;
        _currentTabIndex = _tabController.index;
      });
      
      // Reset and replay animations when tab changes
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _showBookingSheet() {
    final isDarkMode = THelperFunctions.isDarkMode(context); // Check for dark mode

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.75,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white, // Adjust color for light mode
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400, // Adjust color
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Book Your Ride',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black, // Adjust text color
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildServiceSummary(isDarkMode),
                      SizedBox(height: 20),
                      _buildBookingOptions(isDarkMode),
                      SizedBox(height: 30),
                      _buildPaymentOptions(isDarkMode),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Your ride has been booked!'),
                              backgroundColor: Colors.purple,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'CONFIRM BOOKING',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceSummary(bool isDarkMode) {
    if (_selectedService < 0 || _selectedService >= _currentServices.length) {
      return SizedBox.shrink();
    }
    
    final service = _currentServices[_selectedService];
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              service['icon'],
              color: Colors.purple,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['title'],
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  service['price'],
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Est. arrival',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Text(
                service['time'],
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingOptions(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When do you need this service?',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                icon: Icons.flash_on,
                title: 'Instant Ride',
                isSelected: true,
                onTap: () {},
                isDarkMode: isDarkMode,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                icon: Icons.schedule,
                title: 'Schedule',
                isSelected: false,
                onTap: () {},
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOptions(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.credit_card,
                color: Colors.purple,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Visa •••• 4582',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDarkMode ? Colors.white54 : Colors.black54,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.withOpacity(0.2) : isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.purple : isDarkMode ? Colors.white70 : Colors.black54,
              size: 28,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.purple : isDarkMode ? Colors.white70 : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDarkMode),
            _buildTabBar(isDarkMode),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildServicesList(_normalServices, isDarkMode),
                  _buildServicesList(_emergencyServices, isDarkMode),
                  _buildServicesList(_advancedServices, isDarkMode),
                  _buildServicesList(_groupServices, isDarkMode),
                  _buildExtraServicesTab(), // Added Extra tab
                ],
              ),
            ),
            _buildBookRideButton(isDarkMode),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DATRIDE',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Services',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, color: isDarkMode ? Colors.white : Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.purple),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDarkMode) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true, // Made tabs scrollable
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: Colors.purple,
        indicatorWeight: 3,
        labelColor: Colors.purple,
        unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black54,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
      ),
    );
  }

  Widget _buildServicesList(List<Map<String, dynamic>> services, bool isDarkMode) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final double start = 0.2 + (index * 0.1);
            final double end = start + 0.2;
            final double value = math.max(
              0.0,
              math.min(1.0, (_animController.value - start) / (end - start)),
            );
            
            return Transform.translate(
              offset: Offset((1 - value) * 100, 0),
              child: Opacity(
                opacity: value,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedService = _selectedService == index ? -1 : index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedService == index && _currentTabIndex == _tabController.index
                          ? Colors.purple.withOpacity(0.2)
                          : isDarkMode ? Colors.grey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedService == index && _currentTabIndex == _tabController.index
                            ? Colors.purple
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _selectedService == index && _currentTabIndex == _tabController.index
                              ? Colors.purple.withOpacity(0.3)
                              : isDarkMode
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.grey.shade200,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                services[index]['icon'],
                                color: Colors.purple,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    services[index]['title'],
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    services[index]['description'],
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  services[index]['price'],
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      services[index]['time'],
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white70 : Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_selectedService == index && _currentTabIndex == _tabController.index) ...[
                          const SizedBox(height: 16),
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: _currentTabIndex == 1
                                ? [
                                    _buildFeature(Icons.priority_high, 'Priority'),
                                    _buildFeature(Icons.verified_user, 'Certified'),
                                    _buildFeature(Icons.support_agent, '24/7 Support'),
                                  ]
                                : [
                                    _buildFeature(Icons.local_activity, 'Instant Pickup'),
                                    _buildFeature(Icons.cancel, 'Free Cancellation'),
                                    _buildFeature(Icons.chair, 'Comfortable'),
                                  ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.purple,
          size: 22,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBookRideButton(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final double value = 
              Curves.elasticOut.transform(
                math.min(1.0, math.max(0.0, (_animController.value - 0.8) * 5)));
          
          return Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: child,
          );
        },
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedService != -1 && _currentTabIndex == _tabController.index
                ? () => _showBookingSheet()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              disabledBackgroundColor: isDarkMode ? Colors.grey : Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
            ),
            child: Text(
              _selectedService != -1 && _currentTabIndex == _tabController.index
                  ? 'BOOK NOW'
                  : 'SELECT A SERVICE',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExtraServicesTab() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExtraServices()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Go to Extra Services',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}