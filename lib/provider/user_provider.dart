import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/users_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<void> setUser(User user) async {
    _user = user;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id ?? 0);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email ?? '');
    await prefs.setString('profileImage', user.profileImage ?? '');
    notifyListeners();
  }

  Future<void> updateProfileImage(String imageUrl) async {
    if (_user != null) {
      _user = _user!.copyWith(profileImage: imageUrl);
      notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', imageUrl);
    }
  }

  Future<void> loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    String? username = prefs.getString('username');
    String? email = prefs.getString('email');
    String? profileImage = prefs.getString('profileImage');

    if (userId != null && username != null) {
      _user = User(
        id: userId,
        username: username,
        email: email,
        profileImage: profileImage,
      );
      notifyListeners();
    }
  }

  Future<void> clearUser() async {
    _user = null;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

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
