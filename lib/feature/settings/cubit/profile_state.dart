import 'package:equatable/equatable.dart';
import 'package:looped_admin/feature/settings/domain/user_profile.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.isSaving = false,
    this.isSavingImage = false,
  });

  final ProfileStatus status;
  final UserProfile? profile;
  final String? errorMessage;
  final bool isSaving;
  final bool isSavingImage;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? errorMessage,
    bool clearError = false,
    bool? isSaving,
    bool? isSavingImage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSaving: isSaving ?? this.isSaving,
      isSavingImage: isSavingImage ?? this.isSavingImage,
    );
  }

  @override
  List<Object?> get props =>
      [status, profile, errorMessage, isSaving, isSavingImage];
}
