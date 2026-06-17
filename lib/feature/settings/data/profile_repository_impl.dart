import 'package:looped_admin/core/data_scource/remote/dio_consumer.dart';
import 'package:looped_admin/core/data_scource/remote/end_points.dart';
import 'package:looped_admin/feature/settings/domain/profile_repository.dart';
import 'package:looped_admin/feature/settings/domain/user_profile.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required DioConsumer dio}) : _dio = dio;

  final DioConsumer _dio;

  @override
  Future<UserProfile> fetchProfile() async {
    final dynamic response = await _dio.get(EndPoints.profileGet);
    if (response is! Map<String, dynamic>) {
      throw const FormatException('profile_invalid_response');
    }
    if (response['status']?.toString() != 'success') {
      final msg = response['message']?.toString() ?? 'profile_fetch_failed';
      throw Exception(msg);
    }
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('profile_missing_data');
    }
    return UserProfile.fromJson(data);
  }

  @override
  Future<UserProfile> updateProfile(Map<String, dynamic> changes) async {
    if (changes.isEmpty) {
      throw ArgumentError('profile_update_empty_payload');
    }

    final dynamic response = await _dio.post(
      EndPoints.profileUpdate,
      body: changes,
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException('profile_update_invalid_response');
    }
    if (response['status']?.toString() != 'success') {
      final msg = response['message']?.toString() ?? 'profile_update_failed';
      throw Exception(msg);
    }
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return UserProfile.fromJson(data);
    }
    return UserProfile.fromJson(changes);
  }

  @override
  Future<UserProfile> updateProfileImage(String imageBase64) {
    return updateProfile({UserProfile.imageUpdateKey: imageBase64});
  }
}
