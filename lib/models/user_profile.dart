class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String mobileNumber;
  final String profilePicture;
  final String bio;
  final String facebookHandle;
  final String instagramHandle;
  final String twitterHandle;
  final String workAddress;
  final String homeAddress;
  final String dateJoined;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.mobileNumber,
    required this.profilePicture,
    required this.dateJoined,
    required this.facebookHandle,
    required this.instagramHandle,
    required this.twitterHandle,
    required this.workAddress,
    required this.homeAddress,
    required this.bio,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      mobileNumber: json['mobile_number']?.toString() ?? '',
      facebookHandle: json['facebook_handle']?.toString() ?? '',
      instagramHandle: json['instagram_handle']?.toString() ?? '',
      twitterHandle: json['twitter_handle']?.toString() ?? '',
      workAddress: json['work_address']?.toString() ?? '',
      homeAddress: json['home_address']?.toString() ?? '',
      dateJoined: json['date_joined']?.toString() ??
          json['created_at']?.toString() ??
          DateTime.now().toIso8601String(),
      profilePicture: json['profile_image']?.toString() ?? '',
    );
  }
}
