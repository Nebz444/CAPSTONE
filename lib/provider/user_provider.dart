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

  void updateUser({
    String? firstName,
    String? lastName,
    String? middleName,
    String? suffix,
    String? email,
    String? mobileNumber,
    String? homeAddress,
  }) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        username: _user!.username,
        firstName: firstName ?? _user!.firstName,
        lastName: lastName ?? _user!.lastName,
        middleName: middleName ?? _user!.middleName,
        suffix: suffix ?? _user!.suffix,
        email: email ?? _user!.email,
        mobileNumber: mobileNumber ?? _user!.mobileNumber,
        homeAddress: homeAddress ?? _user!.homeAddress,
        birthday: _user!.birthday,
        gender: _user!.gender,
        profileImage: _user!.profileImage,
      );
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