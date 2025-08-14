import 'package:flutter/material.dart';
import 'dart:math' as math;

class BookRide extends StatefulWidget {
  const BookRide({super.key});

  @override
  State<BookRide> createState() => _BookRideState();
}

class _BookRideState extends State<BookRide> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedService = -1;
  
  final List<Map<String, dynamic>> _services = [
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
    {
      'title': 'DatLuxury',
      'icon': Icons.star,
      'description': 'Premium black car service with professional drivers',
      'price': 'From \$19.99',
      'time': '8-12 min'
    },
    {
      'title': 'Bike',
      'icon': Icons.pedal_bike,
      'description': 'Quick and eco-friendly option for short trips',
      'price': 'From \$2.99',
      'time': '2-4 min'
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildServicesList(),
            ),
            _buildBookRideButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.only(
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
                'Services',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.purple),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double value = 
                  Curves.easeInOut.transform(_controller.value);
              return Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Text(
              'Choose your ride experience',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double start = 0.2 + (index * 0.1);
            final double end = start + 0.2;
            final double value = math.max(
              0.0,
              math.min(1.0, (_controller.value - start) / (end - start)),
            );
            
            return Transform.translate(
              offset: Offset((1 - value) * 100, 0),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
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
                color: _selectedService == index
                    ? Colors.purple.withOpacity(0.2)
                    : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedService == index
                      ? Colors.purple
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _selectedService == index
                        ? Colors.purple.withOpacity(0.3)
                        : Colors.black.withOpacity(0.3),
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
                          _services[index]['icon'],
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
                              _services[index]['title'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _services[index]['description'],
                              style: TextStyle(
                                color: Colors.white70,
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
                            _services[index]['price'],
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
                                color: Colors.white70,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _services[index]['time'],
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_selectedService == index) ...[
                    const SizedBox(height: 16),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
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

  Widget _buildBookRideButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
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
        animation: _controller,
        builder: (context, child) {
          final double value = 
              Curves.elasticOut.transform(
                math.min(1.0, math.max(0.0, (_controller.value - 0.8) * 5)));
          
          return Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: child,
          );
        },
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedService != -1 
                ? () {
                    // Handle ride booking
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Booking your ${_services[_selectedService]['title']}',
                        ),
                        backgroundColor: Colors.purple,
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              disabledBackgroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
            ),
            child: Text(
              _selectedService != -1 ? 'BOOK NOW' : 'SELECT A SERVICE',
              style: TextStyle(
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
}