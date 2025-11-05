import 'package:flutter/material.dart';
import 'package:wedding/services/auth_service.dart';
import 'package:wedding/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'settings/settings_card.dart';
import 'category_details_client.dart';

class HomeClientScreen extends StatefulWidget {
  const HomeClientScreen({super.key});

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  // ignore: unused_field
  String? _errorMessage;
  ImageProvider? _profileImage;
  bool _showSettingsCard = false;
  List<dynamic> _recommendedElements = [];
  List<dynamic> _categories = [];

  // Animation controller for the settings icon
  late AnimationController _settingsIconController;
  late Animation<double> _settingsIconAnimation;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchRecommendedElements();
    _fetchCategories();

    // Initialize the animation controller
    _settingsIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Create a tween that rotates the icon 360 degrees
    _settingsIconAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _settingsIconController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _settingsIconController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/api/auth/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _userData = jsonDecode(response.body);

          // Handle profile image URL
          if (_userData?['profileImage'] != null) {
            String imagePath = _userData!['profileImage'];
            // Prepend base URL if it's a relative path
            if (!imagePath.startsWith('http')) {
              imagePath = '${AuthService.baseUrl}$imagePath';
            }
            _profileImage = NetworkImage(imagePath);
          }

          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRecommendedElements() async {
    try {
      final elements = await ApiService.getRecommendedElements();
      setState(() {
        _recommendedElements = elements;
      });
    } catch (e) {
      print('Failed to load recommended elements: $e');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await ApiService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Failed to load categories: $e');
    }
  }

  void _toggleSettingsCard() {
    setState(() {
      _showSettingsCard = !_showSettingsCard;
    });

    // Animate the settings icon
    if (_settingsIconController.isCompleted) {
      _settingsIconController.reverse();
    } else {
      _settingsIconController.forward();
    }
  }

  void _navigateToCategory(String categoryId, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CategoryDetailsClientScreen(
              categoryId: categoryId,
              categoryName: categoryName,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile section
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          // Profile image with modern styling
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child:
                                _isLoading
                                    ? CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.grey.shade200,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.black,
                                            ),
                                      ),
                                    )
                                    : _profileImage != null
                                    ? CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.white,
                                      backgroundImage: _profileImage,
                                      onBackgroundImageError:
                                          (_, __) => const Icon(
                                            Icons.person,
                                            size: 40,
                                          ),
                                    )
                                    : CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.grey.shade100,
                                      child: Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                          ),
                          const SizedBox(width: 20),
                          // Welcome text with modern typography
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome Back",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _isLoading
                                    ? Container(
                                      height: 28,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    )
                                    : Text(
                                      " ${_userData?['name'] ?? 'User'} ! ",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              ],
                            ),
                          ),
                          // Animated settings icon
                          AnimatedBuilder(
                            animation: _settingsIconAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _settingsIconAnimation.value,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.settings,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: _toggleSettingsCard,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Settings card (conditionally shown)
                  if (_showSettingsCard)
                    SettingsCard(onClose: _toggleSettingsCard),

                  // Recommended for you section
                  if (_recommendedElements.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        top: 16.0,
                        bottom: 16.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Recommended for You",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        itemCount: _recommendedElements.length,
                        itemBuilder: (context, index) {
                          final element = _recommendedElements[index];
                          return RecommendedCard(element: element);
                        },
                      ),
                    ),
                  ],

                  // Categories title
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 24.0,
                      top: 28.0,
                      bottom: 12.0,
                      right: 24.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                            width: 4,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                        const Text(
                          "Browse Categories",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6D5FFD), Color(0xFF46C2CB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6D5FFD),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/categoryclient');
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: const Color(0xFF6D5FFD),
                          ),
                          label: const Text("See all"),
                        ),
                      ],
                    ),
                  ),

                  // Categories horizontal list
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _categories.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return SizedBox(
                          width: 120,
                          child: CategoryGridCard(
                            category: category,
                            onTap:
                                () => _navigateToCategory(
                                  category['_id'],
                                  category['name'],
                                ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Recommended Card Widget
class RecommendedCard extends StatelessWidget {
  final dynamic element;

  const RecommendedCard({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey.shade200,
              child:
                  element['image'] != null
                      ? Image.network(
                        'http://10.0.2.2:3000${element['image']}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 40);
                        },
                      )
                      : const Icon(Icons.image, size: 40),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  element['name'] ?? 'Element',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        element['address'] ?? 'Address not available',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${element['price'] ?? '0'} TND",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Category Grid Card Widget
class CategoryGridCard extends StatelessWidget {
  final dynamic category;
  final VoidCallback onTap;

  const CategoryGridCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category Icon/Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child:
                  category['image'] != null
                      ? ClipOval(
                        child: Image.network(
                          'http://10.0.2.2:3000${category['image']}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.category,
                              size: 30,
                              color: Colors.grey.shade400,
                            );
                          },
                        ),
                      )
                      : Icon(
                        Icons.category,
                        size: 30,
                        color: Colors.grey.shade400,
                      ),
            ),
            const SizedBox(height: 12),
            // Category Name
            Text(
              category['name'] ?? 'Category',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
