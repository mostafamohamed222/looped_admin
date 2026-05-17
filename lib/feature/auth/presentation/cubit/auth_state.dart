abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class CheckAppVersionLoading extends AuthState {}

class CheckAppVersionUpToDate extends AuthState {}

class CheckAppVersionForceUpdateRequired extends AuthState {
  final String requiredVersion;

  CheckAppVersionForceUpdateRequired(this.requiredVersion);
}

class CheckAppVersionError extends AuthState {
  final String message;

  CheckAppVersionError(this.message);
}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

class AuthChangePasswordVisibilityState extends AuthState {}

class AuthChangeRememberMeState extends AuthState {}