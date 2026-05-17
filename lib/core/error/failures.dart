import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? message;
  final int? code;
  const Failure({this.message, this.code});
  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message, super.code});
  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  @override
  const CacheFailure({super.message, super.code});
  @override
  List<Object?> get props => [message];
}

class NoInternetFailure extends Failure {
  @override
  const NoInternetFailure({super.message, super.code});
  @override
  List<Object?> get props => [message];
}

class LoginNotCorrectFailure extends Failure {
  @override
  const LoginNotCorrectFailure({super.message, super.code});
  @override
  List<Object?> get props => [message];
}

class DataNotMatchRecordsFailure extends Failure {
  @override
  const DataNotMatchRecordsFailure({super.message, super.code});
}

