import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/users_model.dart';

class LoginController {
  Future<bool> login(User user) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.149/dartdb/dartdb.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );

      // Log the response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}