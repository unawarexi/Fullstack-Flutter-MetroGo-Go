import 'package:datride_mobile/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      image: 'assets/images/onboarding1.png',
      title: 'Ride Anywhere, Anytime',
      description:
          'Book a ride in seconds and get picked up by a nearby driver. Your perfect ride is just a tap away.',
    ),
    OnboardingData(
      image: 'assets/images/onboarding5.png',
      title: 'Real-Time Tracking',
      description:
          'Follow your journey in real-time with live map updates. Know exactly when your driver will arrive.',
    ),
    OnboardingData(
      image: 'assets/images/onboarding3.png',
      title: 'Safe & Seamless Payments',
      description:
          'Multiple payment options with secure transactions. Ride now and pay with ease.',
    ),
    OnboardingData(
      image: 'assets/images/onboarding4.png',
      title: 'Ready To Go?',
      description:
          'Experience the best ride-hailing service. Your comfort and safety are our priority.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Colors.black, Colors.white],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Main content - takes most of the screen
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ), // Add bottom border radius
                  child: CarouselSlider.builder(
                    carouselController: _carouselController,
                    itemCount: _onboardingData.length,
                    options: CarouselOptions(
                      height: screenHeight * 0.85,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                    ),
                    itemBuilder: (context, index, realIndex) {
                      return _buildPage(_onboardingData[index]);
                    },
                  ),
                ),
              ),
              // Bottom section with indicators and button
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black],
                  ),
                ), // Apply gradient styling
                padding: EdgeInsets.only(bottom: bottomPadding + 20, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page indicators
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => _buildPageIndicator(index == _currentPage),
                        ),
                      ),
                    ),
                    // Button section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: _currentPage == _onboardingData.length - 1
                          ? _buildGetStartedButton()
                          : _buildNextButton(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image taking approximately 50% of the screen
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Image.asset(
            data.image,
            fit: BoxFit.cover,
            
          ),
        ),

        // Overlay gradient for better text visibility
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
          ),
        ),

        // Text overlaying the image
        Positioned(
          bottom: 40,
          left: 30,
          right: 30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3.0,
                      color: Color(0x80000000),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                data.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 12,
      width: isActive ? 45 : 12,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEDB200) : const Color(0xFF7C7C7C).withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: () {
        _carouselController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(double.infinity, 56),
        elevation: 5,
      ),
      child: const Text(
        'Next',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return ElevatedButton(
      onPressed: () {
        // Navigate to home screen or login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(double.infinity, 56),
        elevation: 5,
      ),
      child: const Text(
        'Get Started',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}
