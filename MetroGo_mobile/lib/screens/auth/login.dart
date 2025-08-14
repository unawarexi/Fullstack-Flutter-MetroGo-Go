// import 'package:datride_mobile/components/auth_forms/otp_screen.dart';
import 'package:datride_mobile/screens/auth/signup.dart';
import 'package:datride_mobile/screens/bottom_navigation.dart';
import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:form_validator/form_validator.dart';
import 'package:sign_button/sign_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

// Main Authentication Screen that contains both Login and Signup tabs
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: Container(
        decoration:
            isDarkMode
                ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.grey.shade900],
                  ),
                )
                : BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // App Logo
              Center(
                child: Text(
                  'DATRIDE',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your Ride, Your Way',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              // Tab Bar for Login/Signup
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.purple,
                  ),
                  indicatorSize:
                      TabBarIndicatorSize
                          .tab, // Makes the indicator cover the whole tab
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ), // Adds horizontal spacing
                  tabs: const [Tab(text: 'LOGIN'), Tab(text: 'SIGN UP')],
                ),
              ),

              const SizedBox(height: 20),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Login Tab
                    LoginTab(),
                    // Signup Tab
                    SignupTab(),
                  ],
                ),
              ),

              // Driver Text
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildDriverLink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverLink() {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black,
            fontSize: 14,
          ),
          children: [
            TextSpan(text: 'Want to be a driver? '),
            TextSpan(
              text: 'Download the driver app',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () {
                      _launchDriverApp();
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _launchDriverApp() async {
    String url;
    if (kIsWeb) {
      // Web fallback to website
      url = 'https://datride.app/driver';
    } else if (Platform.isAndroid) {
      url = 'https://play.google.com/store/apps/details?id=com.datride.driver';
    } else if (Platform.isIOS) {
      url = 'https://apps.apple.com/app/datride-driver/id123456789';
    } else {
      url = 'https://datride.app/driver';
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch app store')));
      }
    }
  }
}

// Login Tab Content
class LoginTab extends StatefulWidget {
  const LoginTab({super.key});
  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Navigate to OTP screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => OtpVerificationScreen()),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Field
            TextFormField(
              controller: _emailController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
                ),
                prefixIcon: Icon(
                  Icons.email,
                  color: isDarkMode ? Colors.purple : Colors.grey.shade600,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color:
                        isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade400,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.purple),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              ),
              validator:
                  ValidationBuilder()
                      .email('Please enter a valid email')
                      .build(),
            ),
            SizedBox(height: 20),

            // Password Field
            TextFormField(
              controller: _passwordController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
                ),
                prefixIcon: Icon(
                  Icons.lock,
                  color: isDarkMode ? Colors.purple : Colors.grey.shade600,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color:
                        isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade400,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.purple),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              ),
              validator:
                  ValidationBuilder()
                      .minLength(6, 'Password must be at least 6 characters')
                      .build(),
            ),
            SizedBox(height: 15),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Handle forgot password
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.purple),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'LOGIN',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),

            // OR Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade600)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade600)),
              ],
            ),
            SizedBox(height: 30),

            // Social Buttons
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SignInButton(
                  buttonType: ButtonType.google,
                  onPressed: () {
                    // Handle Google sign in
                  },
                  buttonSize: ButtonSize.medium,
                ),
                SignInButton(
                  buttonType: ButtonType.apple,
                  onPressed: () {
                    // Handle Apple sign in
                  },
                  buttonSize: ButtonSize.medium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
