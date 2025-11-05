// lib/screens/signup_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wedding/services/auth_service.dart';
import 'package:wedding/screens/login_screen.dart';
import 'package:wedding/widgets/main_wrapper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  File? _profileImage;
  bool _imageError = false;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
          _imageError = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to select image: ${e.toString()}';
      });
    }
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      // Validate profile image
      if (_profileImage == null) {
        setState(() => _imageError = true);
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _imageError = false;
      });

      try {
        final response = await AuthService.signup(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _phoneController.text.trim(),
          _profileImage,
        );

        await AuthService.saveToken(response['token']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      } catch (e) {
        setState(() => _errorMessage = e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isDesktop || isTablet 
          ? null 
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF5F5F5)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // For larger screens, center the content and limit width
              if (isDesktop) {
                return Center(
                  child: Container(
                    width: 600,
                    margin: const EdgeInsets.all(20),
                    child: _buildSignupContent(isDesktop, isTablet),
                  ),
                );
              } else if (isTablet) {
                return Center(
                  child: Container(
                    width: 600,
                    margin: const EdgeInsets.all(20),
                    child: _buildSignupContent(isDesktop, isTablet),
                  ),
                );
              } else {
                // For mobile, use the original layout with scrolling
                return _buildSignupContent(isDesktop, isTablet);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSignupContent(bool isDesktop, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 0 : 24.0,
        vertical: isDesktop ? 20.0 : 0,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop || isTablet)
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            SizedBox(height: isDesktop ? 20 : 24),
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: isDesktop ? 40 : 32, 
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: Colors.black,
              ),
            ),
            SizedBox(height: isDesktop ? 12 : 8),
            Text(
              'Start planning your perfect day',
              style: TextStyle(
                fontSize: isDesktop ? 20 : 16,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: isDesktop ? 40 : 32),
            
            // Profile image picker
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: isDesktop ? 70 : 55,
                        backgroundColor: Colors.grey[100],
                        backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                        child: _profileImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, 
                                    size: isDesktop ? 40 : 30, 
                                    color: Colors.black54),
                                SizedBox(height: 4),
                                Text(
                                  "Add Photo",
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : 12, 
                                    color: Colors.black54),
                                ),
                              ],
                            )
                          : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: isDesktop ? 44 : 36,
                        width: isDesktop ? 44 : 36,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: isDesktop ? 24 : 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_imageError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Please select a profile image',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: isDesktop ? 16 : null,
                    ),
                  ),
                ),
              ),
            SizedBox(height: isDesktop ? 40 : 32),
            
            // Form fields with styled decoration
            _buildTextField(
              isDesktop: isDesktop,
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: isDesktop ? 24 : 20),
            
            _buildTextField(
              isDesktop: isDesktop,
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: isDesktop ? 24 : 20),
            
            _buildTextField(
              isDesktop: isDesktop,
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.replaceAll(RegExp(r'\D'), '').length < 8) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            SizedBox(height: isDesktop ? 24 : 20),
            
            _buildTextField(
              isDesktop: isDesktop,
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: isDesktop ? 28 : 24),
            
            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: isDesktop ? 16 : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: isDesktop ? 36 : 32),
            
            // Signup button
            Container(
              width: double.infinity,
              height: isDesktop ? 64 : 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: isDesktop ? 20 : 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: isDesktop ? 28 : 24),
            
            // Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: isDesktop ? 18 : null,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 18 : null,
                    ),
                  ),
                  child: const Text('Log In'),
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 28 : 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required bool isDesktop,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black54,
          fontSize: isDesktop ? 18 : null,
        ),
        prefixIcon: Icon(icon, color: Colors.black54, size: isDesktop ? 28 : null),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16, 
          vertical: isDesktop ? 20 : 16,
        ),
      ),
      validator: validator,
    );
  }
}