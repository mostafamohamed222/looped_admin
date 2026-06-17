import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/feature/settings/cubit/profile_save_result.dart';
import 'package:looped_admin/feature/settings/cubit/profile_state.dart';
import 'package:looped_admin/feature/settings/domain/profile_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileState());

  final ProfileRepository _repository;

  Future<void> loadProfile() async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        clearError: true,
      ),
    );
    try {
      final profile = await _repository.fetchProfile();
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: profile,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<ProfileSaveResult> saveProfile({
    required String name,
    required String email,
    required String phoneFieldValue,
  }) async {
    final original = state.profile;
    if (original == null) {
      return ProfileSaveResult.noProfile;
    }

    final changes = original.buildUpdatePayload(
      original: original,
      name: name,
      email: email,
      phoneFieldValue: phoneFieldValue,
    );

    if (changes.isEmpty) {
      return ProfileSaveResult.noChanges;
    }

    emit(
      state.copyWith(
        isSaving: true,
        clearError: true,
      ),
    );

    try {
      final updated = await _repository.updateProfile(changes);
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: updated,
          isSaving: false,
        ),
      );
      return ProfileSaveResult.success;
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: e.toString(),
        ),
      );
      return ProfileSaveResult.failure;
    }
  }

  Future<ProfileSaveResult> updateProfileImage(String imageBase64) async {
    if (state.profile == null) {
      return ProfileSaveResult.noProfile;
    }
    if (imageBase64.trim().isEmpty) {
      return ProfileSaveResult.noChanges;
    }

    emit(
      state.copyWith(
        isSavingImage: true,
        clearError: true,
      ),
    );

    try {
      final updated = await _repository.updateProfileImage(imageBase64);
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: updated,
          isSavingImage: false,
        ),
      );
      return ProfileSaveResult.success;
    } catch (e) {
      emit(
        state.copyWith(
          isSavingImage: false,
          errorMessage: e.toString(),
        ),
      );
      return ProfileSaveResult.failure;
    }
  }
}
