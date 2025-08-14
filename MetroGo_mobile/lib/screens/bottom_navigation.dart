import 'package:datride_mobile/screens/place/places_screen.dart';
import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:datride_mobile/screens/home/home_screen.dart';
import 'package:datride_mobile/screens/my_rides/my_rides.dart';
import 'package:datride_mobile/screens/profile/profile_screen.dart';
import 'package:datride_mobile/screens/ride_services/ride_services.dart'; // Import the new screen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of screens to navigate to
  final List<Widget> _screens = [
    HomeScreen(),
    RideServices(),
    PlacesScreen(),
    MyRidesScreen(),
    ProfileScreen(),
     // Add the new screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced horizontal padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animation
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      shape: BoxShape.circle,
                    )
                  : null,
              padding: EdgeInsets.all(isSelected ? 8 : 0),
              child: Icon(
                icon,
                size: isSelected ? 24 : 22,
                color: isSelected ? Colors.purple : Colors.grey,
              ),
            ),
            SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.purple : Colors.grey,
              ),
            ),
            // Small indicator dot
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 20 : 0,
              margin: EdgeInsets.only(top: 3),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context); // Check for dark mode

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.grey.shade900,
                  ],
                )
              : null, // No gradient for light mode
          color: isDarkMode ? null : Colors.white, // Set white background for light mode
        ),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white, // Adjust color for light mode
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: EdgeInsets.only(top: 6, bottom: 10), // Added bottom padding of 10
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.layers, 'Services', 1),
            _buildNavItem(Icons.place, 'Places', 2), 
            _buildNavItem(Icons.access_time, 'My Rides', 3),
            _buildNavItem(Icons.person, 'Profile', 4),
            
          ],
        ),
      ),
    );
  }
}
