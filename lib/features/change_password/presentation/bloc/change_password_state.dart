import 'package:equatable/equatable.dart';

abstract class ChangePasswordState extends Equatable {
  const ChangePasswordState();

  @override
  List<Object?> get props => [];
}

class ChangePasswordInitial extends ChangePasswordState {}

class ChangePasswordValid extends ChangePasswordState {
  final bool isMinLength;
  final bool isMatch;
  final bool canSubmit;

  const ChangePasswordValid({
    required this.isMinLength,
    required this.isMatch,
    required this.canSubmit,
  });

  @override
  List<Object?> get props => [isMinLength, isMatch, canSubmit];
}

class ChangePasswordInvalid extends ChangePasswordState {
  final bool isMinLength;
  final bool isMatch;

  const ChangePasswordInvalid({
    required this.isMinLength,
    required this.isMatch,
  });

  @override
  List<Object?> get props => [isMinLength, isMatch];
}

class ChangePasswordLoading extends ChangePasswordState {}

class ChangePasswordSuccess extends ChangePasswordState {}

class ChangePasswordError extends ChangePasswordState {
  final String message;

  const ChangePasswordError(this.message);

  @override
  List<Object?> get props => [message];
}
