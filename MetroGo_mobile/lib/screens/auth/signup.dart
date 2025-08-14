import 'package:datride_mobile/components/auth_forms/otp_screen.dart';
import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:sign_button/sign_button.dart';
// Signup Tab Content

class SignupTab extends StatefulWidget {
  const SignupTab({super.key});

  @override
  State<SignupTab> createState() => _SignupTabState();
}

class _SignupTabState extends State<SignupTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      // Navigate to OTP screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OtpVerificationScreen()),
      );
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
            // Name Field
            TextFormField(
              controller: _nameController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
                ),
                prefixIcon: Icon(
                  Icons.person,
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              ),
              validator:
                  ValidationBuilder().required('Name is required').build(),
            ),
            SizedBox(height: 15),

            // Email Field
            TextFormField(
              controller: _emailController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              keyboardType: TextInputType.emailAddress,
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              ),
              validator:
                  ValidationBuilder()
                      .email('Please enter a valid email')
                      .build(),
            ),
            SizedBox(height: 15),

            // Phone Field
            TextFormField(
              controller: _phoneController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
                ),
                prefixIcon: Icon(
                  Icons.phone,
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              ),
              validator:
                  ValidationBuilder()
                      .phone('Please enter a valid phone number')
                      .build(),
            ),
            SizedBox(height: 15),

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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red),
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

            // Confirm Password Field
            TextFormField(
              controller: _confirmPasswordController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: isDarkMode ? Colors.purple : Colors.grey.shade600,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: 30),

            // Signup Button
            ElevatedButton(
              onPressed: _signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'SIGN UP',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),

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
            SizedBox(height: 20),

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
