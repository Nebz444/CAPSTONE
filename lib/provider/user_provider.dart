import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/users_model.dart';

// User Profile Management
class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<void> setUser(User user) async {
    _user = user;

    // Save user profile details in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImage', user.profileImage ?? '');
    await prefs.setString('username', user.username);

    notifyListeners();
  }

  Future<void> updateProfileImage(String imageUrl) async {
    if (_user != null) {
      _user = User(username: _user!.username, profileImage: imageUrl); // New instance
      notifyListeners();

      // Save updated profile image in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', imageUrl);
    }
  }

  Future<void> loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imageUrl = prefs.getString('profileImage');
    String? username = prefs.getString('username');

    if (_user == null && username != null) {
      _user = User(username: username, profileImage: imageUrl);
    }

    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null;
    notifyListeners();

    // Remove user data from SharedPreferences on logout
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('profileImage');
    await prefs.remove('username');
  }
}

// User Authentication State
class LoggedProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<void> initializeLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  Future<void> login() async {
    _isLoggedIn = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }
}
