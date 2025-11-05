import 'package:flutter/material.dart';
import 'package:wedding/services/auth_service.dart';
import 'package:wedding/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'category_details.dart';
import 'chat_tab.dart';
import 'dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  // ignore: unused_field
  String? _errorMessage;
  ImageProvider? _profileImage;
  List<dynamic> _recommendedElements = [];
  List<dynamic> _allElements = [];
  List<dynamic> _categories = [];
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchAllElements();
    _fetchCategories();
    _fetchRecommendedElements();
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

  Future<void> _fetchAllElements() async {
    try {
      // This would need a new API endpoint to fetch all elements
      // For now, we'll combine elements from all categories
      final categories = await ApiService.getCategories();
      List<dynamic> allElements = [];

      for (var category in categories) {
        try {
          final elements = await ApiService.getElementsByCategory(
            category['_id'],
          );
          // Add category name to each element for display
          for (var element in elements) {
            element['categoryName'] = category['name'];
          }
          allElements.addAll(elements);
        } catch (e) {
          print('Failed to load elements for category ${category['_id']}: $e');
        }
      }

      setState(() {
        _allElements = allElements;
      });
    } catch (e) {
      print('Failed to load elements: $e');
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

  Future<void> _toggleRecommendation(
    String elementId,
    bool isCurrentlyRecommended,
  ) async {
    try {
      // ignore: unused_local_variable
      final response = await ApiService.toggleRecommendation(elementId);

      setState(() {
        if (isCurrentlyRecommended) {
          _recommendedElements.removeWhere(
            (element) => element['_id'] == elementId,
          );
        } else {
          final element = _allElements.firstWhere(
            (el) => el['_id'] == elementId,
          );
          _recommendedElements.add(element);
        }

        // Also update the isRecommended flag in the allElements list
        final elementIndex = _allElements.indexWhere(
          (el) => el['_id'] == elementId,
        );
        if (elementIndex != -1) {
          _allElements[elementIndex]['isRecommended'] = !isCurrentlyRecommended;
        }
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCurrentlyRecommended
                ? 'Removed from recommendations'
                : 'Added to recommendations',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Failed to toggle recommendation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update recommendation: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToCategory(String categoryId, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CategoryDetailsScreen(
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
                    // Profile image
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
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
                                    (_, __) =>
                                        const Icon(Icons.person, size: 40),
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
                    // Welcome text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Admin Panel",
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
                                " ${_userData?['name'] ?? 'Admin'} ",
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
                    // Admin badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "ADMIN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildTabButton(0, "Dashboard"),     
                  const SizedBox(width: 8),
                  _buildTabButton(1, "Recommendations"),
                  const SizedBox(width: 8),
                  _buildTabButton(2, "Categories"),
                  const SizedBox(width: 8),
                  _buildTabButton(3, "Chat"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Content based on selected tab
            Expanded(
              child:
                  _selectedTab == 1
                      ? _buildRecommendationsTab()
                      : _selectedTab == 2
                      ? _buildCategoriesTab()
                      : _selectedTab == 3
                      ? const ChatTab()
                      : const Dashboard(),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildTabButton(int tabIndex, String text) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tabIndex;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                _selectedTab == tabIndex ? Colors.black : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _selectedTab == tabIndex ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecommendationsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24.0, bottom: 16.0),
          child: Text(
            "Manage Recommendations",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child:
              _allElements.isEmpty
                  ? const Center(
                    child: Text(
                      "No elements available",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _allElements.length,
                    itemBuilder: (context, index) {
                      final element = _allElements[index];
                      final isRecommended = _recommendedElements.any(
                        (el) => el['_id'] == element['_id'],
                      );

                      return RecommendationItem(
                        element: element,
                        isRecommended: isRecommended,
                        onToggle:
                            () => _toggleRecommendation(
                              element['_id'],
                              isRecommended,
                            ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24.0, bottom: 16.0),
          child: Text(
            "All Categories",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child:
              _categories.isEmpty
                  ? const Center(
                    child: Text(
                      "No categories available",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                  : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return CategoryGridCard(
                        category: category,
                        onTap:
                            () => _navigateToCategory(
                              category['_id'],
                              category['name'],
                            ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

// Recommendation Item Widget
class RecommendationItem extends StatelessWidget {
  final dynamic element;
  final bool isRecommended;
  final VoidCallback onToggle;

  const RecommendationItem({
    super.key,
    required this.element,
    required this.isRecommended,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              element['image'] != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'http://10.0.2.2:3000${element['image']}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 24);
                      },
                    ),
                  )
                  : const Icon(Icons.image, size: 24),
        ),
        title: Text(
          element['name'] ?? 'Unnamed Element',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          element['categoryName'] ?? 'No category',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Switch(
          value: isRecommended,
          onChanged: (value) => onToggle(),
          activeColor: Colors.black,
        ),
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
