import 'package:equatable/equatable.dart';

abstract class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object> get props => [];
}

class PasswordFieldChanged extends ChangePasswordEvent {
  final String current;
  final String newPass;
  final String confirm;

  const PasswordFieldChanged({
    required this.current,
    required this.newPass,
    required this.confirm,
  });

  @override
  List<Object> get props => [current, newPass, confirm];
}

class SubmitChangePassword extends ChangePasswordEvent {
  final String current;
  final String newPass;

  const SubmitChangePassword({required this.current, required this.newPass});

  @override
  List<Object> get props => [current, newPass];
}
