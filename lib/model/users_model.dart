class User {
  int? id;
  String username;
  String? email;
  String? password;
  String? fullName;
  DateTime? birthday;
  String? mobileNumber;
  String? homeAddress;

  User({
    this.id,
    required this.username,
    this.email,
    this.password,
    this.fullName,
    this.birthday,
    this.mobileNumber,
    this.homeAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'username': username,
      'email_address': email,
      'password': password,
      'full_name': fullName,
      'birthday': birthday?.toIso8601String(), // Serialize DateTime as ISO8601 string
      'mobile_number': mobileNumber,
      'home_address': homeAddress,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'],
      username: json['username'],
      email: json['email_address'],
      password: json['password'],
      fullName: json['full_name'],
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      mobileNumber: json['mobile_number'],
      homeAddress: json['home_address'],
    );
  }
}