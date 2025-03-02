import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/users_model.dart';

class LoginController {
  final Client _client = http.Client();
  final String apiUrl = "https://baranguard.shop/API/dartdb.php";

  // Save user session
  Future<void> _saveUserSession(String userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setString('username', username);
  }

  // Clear user session (for logout)

  // Check if user is already logged in
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') != null;
  }

  // Get saved user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Get saved username
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<bool> login(User user) async {
    try {
      final Map<String, dynamic> requestBody = {
        "username": user.username,
        "password": user.password,
        "action": "login"
      };

      debugPrint("Sending login request: ${jsonEncode(requestBody)}");

      final response = await _client.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      debugPrint("Login Response Code: ${response.statusCode}");
      debugPrint("Login Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data != null && data['status'] == 'success') {
          // Save user session
          await _saveUserSession(data['user']['user_id'], data['user']['username']);
          return true;
        }
      }
      return false;
    } catch (e, stacktrace) {
      debugPrint("Login Error: $e");
      debugPrint("Stacktrace: $stacktrace");
      return false;
    }
  }

  Future<User?> getUser(String username) async {
    try {
      final Uri url = Uri.parse("$apiUrl?username=${Uri.encodeComponent(username)}&action=getUser");

      debugPrint("Request URL: $url");

      final response = await _client.get(
        url,
        headers: {"Content-Type": "application/json; charset=UTF-8"},
      );

      debugPrint("Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic>? jsonResponse = jsonDecode(response.body);

          if (jsonResponse != null && jsonResponse.containsKey('user_id')) {
            return User.fromJson(jsonResponse);
          } else {
            debugPrint("Unexpected JSON format: $jsonResponse");
          }
        } catch (e, stacktrace) {
          debugPrint("JSON Decode Error: $e");
          debugPrint("Stacktrace: $stacktrace");
        }
      } else {
        debugPrint("API Error ${response.statusCode}: ${response.body}");
      }
    } catch (e, stacktrace) {
      debugPrint("Exception in getUser: $e");
      debugPrint("Stacktrace: $stacktrace");
    }
    return null;
  }
}
