// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 0);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;
  int _previousPage = 0;
  bool _isLastPage = false;

  // Updated onboarding pages with background images
  final List<OnboardingPage> _onboardingPages = [
    OnboardingPage(
      icon: Icons.celebration,
      title: 'Plan Your Perfect Wedding',
      description:
          'Browse through our curated collection of wedding services and vendors to make your special day unforgettable.',
      color: Color(0xFFFFF0F5),
      backgroundImage: 'assets/onboarding_1.jpg', // Add your image path
    ),
    OnboardingPage(
      icon: Icons.category_outlined,
      title: 'Explore Categories',
      description:
          'Organize your wedding planning with our categorized services from venues to catering and photography.',
      color: Color(0xFFE6F2FF),
      backgroundImage: 'assets/onboarding_2.jpg', // Add your image path
    ),
    OnboardingPage(
      icon: Icons.person_outline,
      title: 'Personalized Experience',
      description:
          'Create your profile and get personalized recommendations based on your preferences and style.',
      color: Color(0xFFF5F0FF),
      backgroundImage: 'assets/onboarding_3.jpg', // Add your image path
    ),
    OnboardingPage(
      icon: Icons.favorite_border,
      title: 'Save Your Favorites',
      description:
          'Bookmark your favorite vendors and services to easily access them later.',
      color: Color(0xFFFFF4E6),
      backgroundImage: 'assets/onboarding_4.jpg', // Add your image path
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background images with cross-fade effect
          _buildAnimatedBackground(),
          
          SafeArea(
            child: Column(
              children: [
                // Skip button with improved styling
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child:
                        !_isLastPage
                            ? TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/Login',
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                ),

                // Content area
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _previousPage = _currentPage;
                        _currentPage = page;
                        _isLastPage = page == _onboardingPages.length - 1;
                        _animationController.reset();
                        _animationController.forward();
                      });
                    },
                    children:
                        _onboardingPages.map((page) {
                          return _buildOnboardingPage(page);
                        }).toList(),
                  ),
                ),

                // Navigation controls with modern design
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    children: [
                      // Page indicators with improved design
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_onboardingPages.length, (
                          index,
                        ) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color:
                                  _currentPage == index
                                        ? Colors.black
                                      : const Color.fromARGB(255, 112, 112, 112).withOpacity(0.3),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      // Next/Get Started button with improved design
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_isLastPage) {
                              Navigator.pushReplacementNamed(context, '/Login');
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _isLastPage ? 'Get Started' : 'Continue',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_onboardingPages[_currentPage].backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _onboardingPages[_currentPage].color.withOpacity(0.05),
              Colors.white.withOpacity(0.4),
            ],
            stops: const [0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(height: 250),

            // Title with animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Description with animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 255, 255, 255),
                        height: 1.6,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String backgroundImage; // New property for background image

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.backgroundImage, // Add this parameter
  });
}