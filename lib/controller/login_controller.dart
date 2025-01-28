import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import '../model/users_model.dart';

class LoginController {
  final Client _client = http.Client();
  final String apiUrl = "http://192.168.100.149/dartdb/dartdb.php";

  Future<bool> login(User user) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": user.username,
          "password": user.password,
        }),
      );

      debugPrint("${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return true;
        }
        return false;
      }
      return false;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<User?> getUser(String username) async {
    try {
      final url = Uri.parse("$apiUrl?username=$username");
      debugPrint("Request URL: $url");

      final response = await _client.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      debugPrint("Raw Response: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final jsonResponse = jsonDecode(response.body);

          // Validate the structure of the response
          if (jsonResponse is Map<String, dynamic> &&
              jsonResponse.containsKey('user_id')) {
            return User.fromJson(jsonResponse);
          } else {
            debugPrint("ERROR: Unexpected JSON format: $jsonResponse");
            return null;
          }
        } catch (e) {
          debugPrint("JSON decode error: $e");
          return null;
        }
      } else {
        debugPrint(
            "ERROR: API returned status code ${response.statusCode}: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("ERROR: Exception occurred in getUser: $e");
      return null;
    }
  }

}