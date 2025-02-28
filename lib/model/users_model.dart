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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'],
      username: json['username'],
      email: json['email_address'],
      password: json['password'],
      lastName: json['last_name'],
      firstName: json['first_name'],
      middleName: json['middle_name'],
      suffix: json['suffix'],
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      mobileNumber: json['mobile_number'],
      homeAddress: json['home_address'],
      profileImage: json['profile_image_path'], // ✅ Retrieve profile image from API response
    );
  }
}