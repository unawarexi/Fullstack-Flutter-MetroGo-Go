import 'package:datride_mobile/screens/bottom_navigation.dart';
import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:flutter/material.dart';

import 'package:pin_code_fields/pin_code_fields.dart'; // OTP Verification Screen

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});
  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
 
  bool _isVerifying = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
            _startCountdown();
          }
        });
      }
    });
  }

  void _verifyOtp() {
    if (_otpController.text.length == 4) {
      setState(() {
        _isVerifying = true;
      });

      // Simulate verification
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isVerifying = false;
          });
          // Navigate to mainScreen on success
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        }
      });
    }
  }

  void _resendCode() {
    if (_countdown == 0) {
      setState(() {
        _countdown = 60;
      });
      _startCountdown();

      // Show snackbar for resend
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Verification code resent!')));
    }
  }

  @override
  Widget build(BuildContext context) {
     final isDarkMode = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: Container(
        decoration: isDarkMode ? BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.grey.shade900],
          ),
        ) : BoxDecoration(color: Colors.white),
       
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      // App Logo
                      Text(
                        'DATRIDE',
                        style: TextStyle(
                          color:  isDarkMode ? Colors.white : Colors.black,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 50),

                      // Heading
                      Text(
                        'Verification Code',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),

                      // Description
                      Text(
                        'We have sent a verification code to your phone number',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 50),

                      // OTP Input
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: _otpController,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 60,
                          fieldWidth: 60,
                          activeFillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                          activeColor: Colors.purple,
                          inactiveFillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                          inactiveColor: Colors.grey.shade600,
                          selectedFillColor: isDarkMode ? Colors.grey.shade700 : Colors.white,
                          selectedColor: Colors.purple,
                        ),
                        animationDuration: Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        textStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 20,
                        ),
                        onCompleted: (v) {
                          _verifyOtp();
                        },
                        onChanged: (value) {
                          // Handle value change
                        },
                      ),
                      SizedBox(height: 40),

                      // Verify Button
                      ElevatedButton(
                        onPressed: _isVerifying ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 40,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child:
                            _isVerifying
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  'VERIFY',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                      SizedBox(height: 30),

                      // Resend Code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive code? ",
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: _countdown == 0 ? _resendCode : null,
                            child: Text(
                              _countdown > 0
                                  ? "Resend in $_countdown seconds"
                                  : "Resend Code",
                              style: TextStyle(
                                color:
                                    _countdown > 0
                                        ? Colors.grey
                                        : Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
