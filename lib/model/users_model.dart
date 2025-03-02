class User {
  int? id;
  String username;
  String? email;
  String? password;
  String? lastName;
  String? firstName;
  String? middleName;
  String? suffix;
  DateTime? birthday;
  String? mobileNumber;
  String? homeAddress;
  String? profileImage; // ✅ Added profile image field

  User({
    this.id,
    required this.username,
    this.email,
    this.password,
    this.lastName,
    this.firstName,
    this.middleName,
    this.suffix,
    this.birthday,
    this.mobileNumber,
    this.homeAddress,
    this.profileImage, // ✅ Added profile image field
  });

  // Convert User object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'username': username,
      'email_address': email,
      'password': password,
      'last_name': lastName,
      'first_name': firstName,
      'middle_name': middleName,
      'suffix': suffix,
      'birthday': birthday?.toIso8601String(), // Serialize DateTime as ISO8601 string
      'mobile_number': mobileNumber,
      'home_address': homeAddress,
      'profile_image_path': profileImage, // ✅ Added profile image field
    };
  }

  // Create a User object from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] as int?,
      username: json['username'] as String,
      email: json['email_address'] as String?,
      password: json['password'] as String?,
      lastName: json['last_name'] as String?,
      firstName: json['first_name'] as String?,
      middleName: json['middle_name'] as String?,
      suffix: json['suffix'] as String?,
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'] as String)
          : null,
      mobileNumber: json['mobile_number'] as String?,
      homeAddress: json['home_address'] as String?,
      profileImage: json['profile_image_path'] as String?, // ✅ Retrieve profile image from API response
    );
  }

  // Create a copy of the User object with updated fields
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? lastName,
    String? firstName,
    String? middleName,
    String? suffix,
    DateTime? birthday,
    String? mobileNumber,
    String? homeAddress,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      suffix: suffix ?? this.suffix,
      birthday: birthday ?? this.birthday,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      homeAddress: homeAddress ?? this.homeAddress,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}