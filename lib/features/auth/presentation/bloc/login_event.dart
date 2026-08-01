import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String identifier;
  final String password;

  const LoginSubmitted({required this.identifier, required this.password});

  @override
  List<Object?> get props => [identifier, password];
}

class ForgotPasswordRequested extends LoginEvent {
  final String email;
  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
