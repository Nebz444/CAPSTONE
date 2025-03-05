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

  Future<void> updateUserDetails({
    required String lastName,
    required String firstName,
    required String middleName,
    required String suffix,
    required String email,
    required String mobileNumber,
    required String homeAddress,
  }) async {
    if (_user != null) {
      // Update the user object with new details
      _user = _user!.copyWith(
        lastName: lastName,
        firstName: firstName,
        middleName: middleName,
        suffix: suffix,
        email: email,
        mobileNumber: mobileNumber,
        homeAddress: homeAddress,
      );

      // Save updated details to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastName', lastName);
      await prefs.setString('firstName', firstName);
      await prefs.setString('middleName', middleName);
      await prefs.setString('suffix', suffix);
      await prefs.setString('email', email);
      await prefs.setString('mobileNumber', mobileNumber);
      await prefs.setString('homeAddress', homeAddress);

      notifyListeners();
    }
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
    String? lastName = prefs.getString('lastName');
    String? firstName = prefs.getString('firstName');
    String? middleName = prefs.getString('middleName');
    String? suffix = prefs.getString('suffix');
    String? mobileNumber = prefs.getString('mobileNumber');
    String? homeAddress = prefs.getString('homeAddress');

    if (userId != null && username != null) {
      _user = User(
        id: userId,
        username: username,
        email: email,
        profileImage: profileImage,
        lastName: lastName,
        firstName: firstName,
        middleName: middleName,
        mobileNumber: mobileNumber,
        homeAddress: homeAddress,
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