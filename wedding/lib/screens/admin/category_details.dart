// category_details.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'element_details.dart';
import '../../services/api_service.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String? categoryImage;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.categoryImage,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CategoryElement> _elements = [];
  List<CategoryElement> _displayedElements = [];
  bool _isLoading = true;

  // Controllers for new element dialog
  final TextEditingController _elementNameController = TextEditingController();
  final TextEditingController _elementAddressController =
      TextEditingController();
  final TextEditingController _elementPriceController = TextEditingController();
  final TextEditingController _elementDescriptionController =
      TextEditingController();
  File? _newElementImage;

  // Controllers for edit element dialog
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editAddressController = TextEditingController();
  final TextEditingController _editPriceController = TextEditingController();
  final TextEditingController _editDescriptionController =
      TextEditingController();
  File? _editElementImage;
  String? _currentEditElementId;

  final ImagePicker _imagePicker = ImagePicker();

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
    _elementNameController.dispose();
    _elementAddressController.dispose();
    _elementPriceController.dispose();
    _elementDescriptionController.dispose();
    _editNameController.dispose();
    _editAddressController.dispose();
    _editPriceController.dispose();
    _editDescriptionController.dispose();
    super.dispose();
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _newElementImage = File(pickedFile.path));
    }
  }

  // Create new element
  void _createNewElement() async {
    if (_elementNameController.text.isEmpty) {
      _showErrorSnackbar('Element name is required');
      return;
    }

    if (_newElementImage == null) {
      _showErrorSnackbar('Element image is required');
      return;
    }

    try {
      await ApiService.createElement(
        widget.categoryId,
        _elementNameController.text,
        _elementAddressController.text,
        _elementPriceController.text,
        _elementDescriptionController.text,
        _newElementImage!,
      );

      // Refresh elements list
      await _loadElements();

      // Reset form
      _elementNameController.clear();
      _elementAddressController.clear();
      _elementPriceController.clear();
      _elementDescriptionController.clear();
      _newElementImage = null;

      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackbar('Failed to create element: $e');
    }
  }

  // Delete element
  void _deleteElement(String elementId) async {
    try {
      await ApiService.deleteElement(elementId);
      await _loadElements(); // Refresh list
    } catch (e) {
      _showErrorSnackbar('Failed to delete element: $e');
    }
  }

  // Initialize edit controllers
  void _initializeEditControllers(CategoryElement element) {
    _editNameController.text = element.name;
    _editAddressController.text = element.address;
    _editPriceController.text = element.price;
    _editDescriptionController.text = element.description;
    _editElementImage = null;
    _currentEditElementId = element.id;
  }

  // Update element
  void _updateElement() async {
    if (_editNameController.text.isEmpty) {
      _showErrorSnackbar('Element name is required');
      return;
    }

    try {
      await ApiService.updateElement(
        _currentEditElementId!,
        _editNameController.text,
        _editAddressController.text,
        _editPriceController.text,
        _editDescriptionController.text,
        _editElementImage,
      );

      // Refresh elements list
      await _loadElements();

      // Close dialog
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackbar('Failed to update element: $e');
    }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddElementDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildElementCard(CategoryElement element) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ElementDetailsScreen(
                      elementId: element.id,
                      elementName: element.name,
                      elementImage: element.image,
                      elementImageUrl:
                          element.imageUrl != null
                              ? 'http://10.0.2.2:3000${element.imageUrl}'
                              : '',
                      elementAddress: element.address,
                      elementPrice: element.price,
                      elementDescription: element.description,
                    ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image container with hero animation
                Hero(
                  tag: 'element-image-${element.id}',
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child:
                          element.image != null
                              ? Image.file(element.image!, fit: BoxFit.cover)
                              : element.imageUrl != null
                              ? Image.network(
                                'http://10.0.2.2:3000${element.imageUrl}',
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      strokeWidth: 2,
                                      color: Theme.of(context).primaryColor,
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
                ),

                // Content container
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Element Name
                        Text(
                          element.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Address with icon
                        Row(
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
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Price with icon
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money_rounded,
                              size: 16,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${element.price} TND",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),

                        // Buttons row
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap:
                                    () => _showEditElementDialog(
                                      context,
                                      element,
                                    ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.edit_rounded,
                                    size: 20,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => _showDeleteDialog(element.id),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                    color: Colors.redAccent,
                                  ),
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
        ),
      ),
    );
  }

  void _showDeleteDialog(String elementId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this element?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteElement(elementId);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditElementDialog(BuildContext context, CategoryElement element) {
    _initializeEditControllers(element);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Edit Element'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _editNameController,
                        decoration: const InputDecoration(
                          labelText: 'Element Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _editAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _editPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _editDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      // Current image preview
                      if (element.imageUrl != null)
                        Column(
                          children: [
                            const Text('Current Image:'),
                            const SizedBox(height: 8),
                            Image.network(
                              'http://10.0.2.2:3000${element.imageUrl}',
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      // Image picker
                      GestureDetector(
                        onTap: () async {
                          final pickedFile = await _imagePicker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null) {
                            setState(
                              () => _editElementImage = File(pickedFile.path),
                            );
                          }
                        },
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child:
                              _editElementImage != null
                                  ? Image.file(
                                    _editElementImage!,
                                    fit: BoxFit.cover,
                                  )
                                  : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                      Text('Tap to change image'),
                                    ],
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _updateElement,
                    child: const Text('Save Changes'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showAddElementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Element'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _elementNameController,
                    decoration: const InputDecoration(
                      labelText: 'Element Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _elementAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _elementPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _elementDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child:
                          _newElementImage != null
                              ? Image.file(_newElementImage!, fit: BoxFit.cover)
                              : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  Text('Tap to add image'),
                                ],
                              ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _createNewElement,
                child: const Text('Create'),
              ),
            ],
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
