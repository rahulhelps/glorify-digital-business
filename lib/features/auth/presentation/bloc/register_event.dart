import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String? referredBy;

  const RegisterSubmitted({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    this.referredBy,
  });

  @override
  List<Object?> get props => [name, phone, email, password, referredBy];
}
