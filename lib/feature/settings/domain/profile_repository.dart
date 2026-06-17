import 'package:looped_admin/feature/settings/domain/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> fetchProfile();

  Future<UserProfile> updateProfile(Map<String, dynamic> changes);

  Future<UserProfile> updateProfileImage(String imageBase64);
}
