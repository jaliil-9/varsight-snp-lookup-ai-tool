class ProfileModel {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String profilePicture;

  ProfileModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.profilePicture = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'profilepicture': profilePicture,
    };
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilepicture'] ?? '',
    );
  }
}
