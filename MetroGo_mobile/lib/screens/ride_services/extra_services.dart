import 'package:datride_mobile/screens/ride_services/ride_services.dart';
import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:flutter/material.dart';

class ExtraServices extends StatefulWidget {
  const ExtraServices({super.key});

  @override
  State<ExtraServices> createState() => _ExtraServicesState();
}

class _ExtraServicesState extends State<ExtraServices> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<Map<String, dynamic>> _extraServices = [
    {
      'title': 'Corporate Events',
      'icon': Icons.business,
      'description': 'Transportation services for corporate events',
      'color': Colors.blue,
    },
    {
      'title': 'Wedding Transport',
      'icon': Icons.celebration,
      'description': 'Luxury vehicles for your special day',
      'color': Colors.pink,
    },
    {
      'title': 'Airport Transfer',
      'icon': Icons.flight,
      'description': 'Reliable rides to and from the airport',
      'color': Colors.amber,
    },
    {
      'title': 'Long Distance',
      'icon': Icons.map,
      'description': 'Comfortable rides for longer journeys',
      'color': Colors.green,
    },
    {
      'title': 'Chauffeur Service',
      'icon': Icons.privacy_tip,
      'description': 'Professional chauffeurs for any occasion',
      'color': Colors.deepPurple,
    },
    {
      'title': 'Cargo & Delivery',
      'icon': Icons.inventory_2,
      'description': 'Reliable package and cargo delivery',
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: _buildServiceGrid(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: Icon(Icons.message, color: Colors.white),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Contact support for custom services'),
              backgroundColor: Colors.purple,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Extra Services',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.more_vert,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Specialized services for all your needs',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 20),
          TextField(
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            
            decoration: InputDecoration(
              hintText: 'Search for services',
              hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
              prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white54 : Colors.black54),
              filled: true,
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white ,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildServiceGrid() {
  return AnimatedBuilder(
    animation: _animController,
    builder: (context, child) {
      final isDarkMode = THelperFunctions.isDarkMode(context);
      return GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _extraServices.length,
        itemBuilder: (context, index) {
          final double start = 0.1 + (index * 0.1);
          final double end = start + 0.2;
          final double value = Curves.easeOut.transform(
            _animController.value > start
                ? _animController.value < end
                    ? (_animController.value - start) / (end - start)
                    : 1.0
                : 0.0,
          );

          return Transform.scale(
            scale: 0.5 + (value * 0.5),
            child: Opacity(
              opacity: value,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RideServices(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _extraServices[index]['color'].withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _extraServices[index]['color'].withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _extraServices[index]['icon'],
                          color: _extraServices[index]['color'],
                          size: 36,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        _extraServices[index]['title'],
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          _extraServices[index]['description'],
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RideServices(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _extraServices[index]['color'],
                          foregroundColor: isDarkMode ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size(0, 0),
                        ),
                        child: Text(
                          'Learn More',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
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
}