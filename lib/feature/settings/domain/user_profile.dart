class UserProfile {
  const UserProfile({
    required this.city,
    required this.email,
    required this.mobile,
    required this.name,
    required this.phone,
    required this.street,
    required this.street2,
    required this.imageUrl,
  });

  final String city;
  final String email;
  final String mobile;
  final String name;
  final String phone;
  final String street;
  final String street2;
  final String imageUrl;

  static const String imageUpdateKey = 'image_1920';

  String get displayPhone => phone.isNotEmpty ? phone : mobile;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      city: json['city']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      street2: json['street2']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }

  /// Returns only fields that differ from [original] for the profile update API.
  Map<String, dynamic> buildUpdatePayload({
    required UserProfile original,
    required String name,
    required String email,
    required String phoneFieldValue,
    String? mobile,
    String? street,
    String? street2,
    String? city,
  }) {
    final payload = <String, dynamic>{};
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedPhone = phoneFieldValue.trim();

    if (trimmedName != original.name) {
      payload['name'] = trimmedName;
    }
    if (trimmedEmail != original.email) {
      payload['email'] = trimmedEmail;
    }
    if (trimmedPhone != original.displayPhone) {
      if (original.phone.isNotEmpty) {
        payload['phone'] = trimmedPhone;
      } else if (original.mobile.isNotEmpty) {
        payload['mobile'] = trimmedPhone;
      } else {
        payload['phone'] = trimmedPhone;
      }
    }

    if (mobile != null && mobile.trim() != original.mobile) {
      payload['mobile'] = mobile.trim();
    }
    if (street != null && street.trim() != original.street) {
      payload['street'] = street.trim();
    }
    if (street2 != null && street2.trim() != original.street2) {
      payload['street2'] = street2.trim();
    }
    if (city != null && city.trim() != original.city) {
      payload['city'] = city.trim();
    }

    return payload;
  }
}
