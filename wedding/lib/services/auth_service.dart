// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['msg']);
    }
  }

  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
    String phone,
    File? profileImage,
  ) async {
    try {
      var uri = Uri.parse('$baseUrl/api/auth/register');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['phone'] = phone;

      // Add image if exists
      if (profileImage != null) {
        var fileStream = http.ByteStream(profileImage.openRead());
        var length = await profileImage.length();

        // Get file extension
        final extension = profileImage.path.split('.').last.toLowerCase();

        // Determine MIME type based on extension
        String mimeType;
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'png':
            mimeType = 'image/png';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          default:
            mimeType = 'application/octet-stream';
        }

        var multipartFile = http.MultipartFile(
          'profileImage',
          fileStream,
          length,
          filename: 'profile.${extension}',
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseData);
      } else {
        // Handle JSON responses
        if (responseData.startsWith('{')) {
          final errorData = jsonDecode(responseData);
          throw Exception(errorData['msg'] ?? 'Signup failed');
        } else {
          throw Exception(responseData);
        }
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // change password
  static Future<void> changePassword(String newPassword) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/api/auth/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'newPassword': newPassword}),
      );

      print('Password change response: ${response.statusCode}');
      print('Password change response body: ${response.body}');

      if (response.statusCode == 200) {
        return;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['msg'] ??
              'Failed to change password. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Password change error: $e');
      rethrow;
    }
  }
}
