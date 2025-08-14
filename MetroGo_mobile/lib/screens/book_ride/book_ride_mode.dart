import 'package:datride_mobile/screens/book_ride/book_ride_options.dart';
import 'package:flutter/material.dart';
import 'package:datride_mobile/utils/helper_functions.dart';

class BookRideMode extends StatefulWidget {
  const BookRideMode({super.key});

  @override
  State<BookRideMode> createState() => _BookRideModeState();
}

class _BookRideModeState extends State<BookRideMode> {
  // Transport purpose categories
  final List<String> transportPurposes = ['People', 'Items', 'Others'];
  
  // Currently selected purpose
  int _selectedPurpose = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book Your Ride',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Purpose Selection Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(transportPurposes.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPurpose = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedPurpose == index 
                            ? Colors.purple 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          transportPurposes[index],
                          style: TextStyle(
                            color: _selectedPurpose == index 
                                ? Colors.white 
                                : (isDarkMode ? Colors.white70 : Colors.black),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Transport Options will be shown based on selected purpose
          Expanded(
            child: BookRideOptions(
              purpose: transportPurposes[_selectedPurpose],
            ),
          ),
        ],
      ),
    );
  }
}