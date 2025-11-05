// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:wedding/services/auth_service.dart';
import 'package:wedding/screens/signup_screen.dart';
import 'package:wedding/widgets/main_wrapper.dart';
import 'package:wedding/widgets/main_wrapper_admin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await AuthService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        await AuthService.saveToken(response['token']);

        if (response['role'] == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainWrapperAdmin()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainWrapper()),
          );
        }
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
                    width: 500,
                    margin: const EdgeInsets.all(20),
                    child: _buildLoginContent(isDesktop, isTablet),
                  ),
                );
              } else if (isTablet) {
                return Center(
                  child: Container(
                    width: 500,
                    margin: const EdgeInsets.all(20),
                    child: _buildLoginContent(isDesktop, isTablet),
                  ),
                );
              } else {
                // For mobile, use the original layout with scrolling
                return _buildLoginContent(isDesktop, isTablet);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginContent(bool isDesktop, bool isTablet) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 0 : 24.0,
        vertical: isDesktop ? 20.0 : 0,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: isDesktop ? 40 : 60),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.05),
              ),
              child: Icon(
                Icons.favorite,
                size: isDesktop ? 60 : 50,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isDesktop ? 20 : 24),
            Text(
              '3arsoulii.tn',
              style: TextStyle(
                fontSize: isDesktop ? 32 : 28,
                fontWeight: FontWeight.w400,
                letterSpacing: 3.0,
                color: Colors.black87,
                fontFamily: 'Comic Sans MS',
                shadows: const [
                  Shadow(
                    color: Colors.black12,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
                height: 1.2,
                decoration: TextDecoration.none,
                decorationThickness: 1,
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            Text(
              'Sign in to continue',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: isDesktop ? 40 : 60),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.black54),
                hintText: 'your@email.com',
                hintStyle: const TextStyle(color: Colors.black38),
                prefixIcon: Icon(Icons.email_outlined, color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.black54, width: 1),
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.03),
                contentPadding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 20 : 16,
                  horizontal: 16,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            SizedBox(height: isDesktop ? 20 : 24),
            TextFormField(
              controller: _passwordController,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.black54),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.black54, width: 1),
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.03),
                contentPadding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 20 : 16,
                  horizontal: 16,
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            SizedBox(height: isDesktop ? 20 : 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Forgot password logic
                },
                style: TextButton.styleFrom(foregroundColor: Colors.black54),
                child: Text('Forgot Password?'),
              ),
            ),
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: isDesktop ? 30 : 40),
            SizedBox(
              width: double.infinity,
              height: isDesktop ? 64 : 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Colors.black.withOpacity(0.25),
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          'SIGN IN',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
            SizedBox(height: isDesktop ? 30 : 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account?',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: isDesktop ? 16 : null,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.black87),
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isDesktop ? 16 : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 30 : 40),
          ],
        ),
      ),
    );
  }
}
