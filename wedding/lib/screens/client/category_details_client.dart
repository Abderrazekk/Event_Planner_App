// category_details.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'element_details_client.dart';
import '../../services/api_service.dart';

class CategoryDetailsClientScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String? categoryImage;

  const CategoryDetailsClientScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.categoryImage,
  });

  @override
  State<CategoryDetailsClientScreen> createState() => _CategoryDetailsClientScreenState();
}

class _CategoryDetailsClientScreenState extends State<CategoryDetailsClientScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CategoryElement> _elements = [];
  List<CategoryElement> _displayedElements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadElements();
  }

  Future<void> _loadElements() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getElementsByCategory(widget.categoryId);
      setState(() {
        _elements = data.map((json) => CategoryElement.fromJson(json)).toList();
        _displayedElements = _elements;
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnackbar('Failed to load elements: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Search filter
  void _filterElements(String query) {
    setState(() {
      _displayedElements =
          _elements.where((element) {
            return element.name.toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.categoryName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              '${_displayedElements.length} elements',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search elements...',
                hintStyle: TextStyle(
                  color: const Color.fromARGB(255, 112, 112, 112),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color.fromARGB(255, 36, 36, 36),
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: const Color.fromARGB(255, 49, 49, 49),
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _displayedElements = _elements;
                            });
                          },
                        )
                        : null,
                filled: true,
                fillColor: const Color.fromARGB(255, 241, 241, 241),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                isDense: true,
              ),
              onChanged: _filterElements,
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _displayedElements.isEmpty
              ? const Center(child: Text('No elements found'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _displayedElements.length,
                itemBuilder: (context, index) {
                  final element = _displayedElements[index];
                  return _buildElementCard(element);
                },
              ),
    );
  }

  Widget _buildElementCard(CategoryElement element) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ElementDetailsClientScreen(
                  elementId: element.id,
                  elementName: element.name,
                  elementImage: element.image,
                  elementImageUrl: element.imageUrl != null
                      ? 'http://10.0.2.2:3000${element.imageUrl}'
                      : '',
                  elementAddress: element.address,
                  elementPrice: element.price,
                  elementDescription: element.description,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with hero animation
              Hero(
                tag: 'element-image-${element.id}',
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: element.image != null
                      ? Image.file(element.image!, fit: BoxFit.cover)
                      : element.imageUrl != null
                          ? Image.network(
                              'http://10.0.2.2:3000${element.imageUrl}',
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.broken_image_rounded,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                Icons.image_rounded,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                ),
              ),

              // Content container
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Element Name
                    Text(
                      element.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Info row with location and price
                    Row(
                      children: [
                        // Location chip
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    element.address,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[800],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Price chip
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${element.price} TND",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
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
}

class CategoryElement {
  final String id;
  final String name;
  final String address;
  final String price;
  final String description;
  final File? image;
  final String? imageUrl;

  CategoryElement({
    required this.id,
    required this.name,
    required this.address,
    required this.price,
    required this.description,
    this.image,
    this.imageUrl,
  });

  factory CategoryElement.fromJson(Map<String, dynamic> json) {
    return CategoryElement(
      id: json['_id'],
      name: json['name'],
      address: json['address'],
      price: json['price'],
      description: json['description'],
      imageUrl: json['image'],
    );
  }
}