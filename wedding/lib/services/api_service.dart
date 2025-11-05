import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//********************** category ***********************/
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  static Future<Map<String, String>> _getHeaders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      throw Exception('Failed to get headers: ${e.toString()}');
    }
  }

  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/api/categories'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // services/api_service.dart
  static Future<Map<String, dynamic>> createCategory(
    String name,
    File image,
  ) async {
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/categories'),
      );

      // Add token to headers
      request.headers.addAll(headers);

      // Add name field
      request.fields['name'] = name;

      // Add image file
      final fileStream = http.ByteStream(image.openRead());
      final length = await image.length();
      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        length,
        filename: image.path.split('/').last,
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        return jsonDecode(responseBody);
      } else {
        // Parse error message from server
        final errorData = jsonDecode(responseBody);
        final errorMsg =
            errorData['msg'] ?? errorData['message'] ?? 'Unknown error';
        throw Exception('$errorMsg (Status: $statusCode)');
      }
    } catch (e) {
      // Handle network or other exceptions
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> updateCategory(
    String id,
    String name,
    File? image,
  ) async {
    final headers = await _getHeaders();
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/api/categories/$id'),
    );
    request.headers.addAll(headers);
    request.fields['name'] = name;

    if (image != null) {
      final fileStream = http.ByteStream(image.openRead());
      final length = await image.length();
      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        length,
        filename: image.path.split('/').last,
      );
      request.files.add(multipartFile);
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to update category');
    }
  }

  // Update deleteCategory method in ApiService.dart
  static Future<void> deleteCategory(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/categories/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return;
      } else {
        // Parse error message if available
        final responseBody = jsonDecode(response.body);
        final errorMsg =
            responseBody['msg'] ?? responseBody['message'] ?? 'Unknown error';
        throw Exception('$errorMsg (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /******************** elements  *********************/

  // Add to api_service.dart
  static Future<List<dynamic>> getElementsByCategory(String categoryId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/elements/category/$categoryId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load elements');
    }
  }

  static Future<Map<String, dynamic>> createElement(
    String categoryId,
    String name,
    String address,
    String price,
    String description,
    File image,
  ) async {
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/elements'),
      );

      request.headers.addAll(headers);
      request.fields['category'] = categoryId;
      request.fields['name'] = name;
      request.fields['address'] = address;
      request.fields['price'] = price;
      request.fields['description'] = description;

      final fileStream = http.ByteStream(image.openRead());
      final length = await image.length();
      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        length,
        filename: image.path.split('/').last,
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return jsonDecode(responseBody);
      } else {
        final errorData = jsonDecode(responseBody);
        throw Exception(errorData['msg'] ?? 'Failed to create element');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> updateElement(
    String elementId,
    String name,
    String address,
    String price,
    String description,
    File? image, // Optional for partial updates
  ) async {
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/elements/$elementId'),
      );

      request.headers.addAll(headers);
      request.fields['name'] = name;
      request.fields['address'] = address;
      request.fields['price'] = price;
      request.fields['description'] = description;

      if (image != null) {
        final fileStream = http.ByteStream(image.openRead());
        final length = await image.length();
        final multipartFile = http.MultipartFile(
          'image',
          fileStream,
          length,
          filename: image.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        final errorData = jsonDecode(responseBody);
        throw Exception(errorData['msg'] ?? 'Failed to update element');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<void> deleteElement(String elementId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/elements/$elementId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete element');
    }
  }

  // Add to api_service.dart
  static Future<void> toggleMarkedDate(String elementId, DateTime date) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/schedules'),
      headers: headers,
      body: jsonEncode({
        'elementId': elementId,
        'date': date.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to toggle date');
    }
  }

  static Future<Set<DateTime>> getMarkedDates(String elementId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/schedules/$elementId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> dates = data['markedDates'];
      return dates.map((d) => DateTime.parse(d)).toSet();
    } else {
      throw Exception('Failed to load marked dates');
    }
  }

  static Future<void> unmarkDate(String elementId, DateTime date) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/schedules/unmark'),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'elementId': elementId,
        'date': date.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to unmark date: ${response.body}');
    }
  }

  // Add to api_service.dart
  static Future<List<dynamic>> getElementMedia(String elementId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/media/element/$elementId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load media');
    }
  }

  static Future<Map<String, dynamic>> uploadMedia(
    String elementId,
    File mediaFile,
    String type, // 'photo' or 'video'
  ) async {
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/media'),
      );

      request.headers.addAll(headers);
      request.fields['elementId'] = elementId;
      request.fields['type'] = type;

      final fileStream = http.ByteStream(mediaFile.openRead());
      final length = await mediaFile.length();
      final multipartFile = http.MultipartFile(
        'media',
        fileStream,
        length,
        filename: mediaFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return jsonDecode(responseBody);
      } else {
        final errorData = jsonDecode(responseBody);
        throw Exception(errorData['msg'] ?? 'Failed to upload media');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<void> deleteMedia(String mediaId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/media/$mediaId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete media');
    }
  }

  // Toggle recommendation status
  static Future<Map<String, dynamic>> toggleRecommendation(
    String elementId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/api/elements/$elementId/toggle-recommendation'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['msg'] ?? 'Failed to toggle recommendation');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get recommended elements
  static Future<List<dynamic>> getRecommendedElements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/elements/recommended'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load recommended elements');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  //dashboard
  static Future<List<dynamic>> getUserStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/user-stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user stats');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
