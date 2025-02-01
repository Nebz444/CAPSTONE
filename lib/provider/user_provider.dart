import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/users_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) async {
    _user = user;
    notifyListeners();

    // Save user profile image in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImage', user.profileImage ?? '');
  }

  void updateProfileImage(String imageUrl) async {
    if (_user != null) {
      _user!.profileImage = imageUrl;
      notifyListeners();

      // Save updated profile image in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', imageUrl);
    }
  }

  Future<void> loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imageUrl = prefs.getString('profileImage');

    if (_user != null && imageUrl != null && imageUrl.isNotEmpty) {
      _user!.profileImage = imageUrl;
      notifyListeners();
    }
  }

  void clearUser() async {
    _user = null;
    notifyListeners();

    // Remove profile image from SharedPreferences on logout
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('profileImage');
  }
}
