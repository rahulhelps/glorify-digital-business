import 'package:equatable/equatable.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;
  const UserLoaded(this.user);
  @override
  List<Object> get props => [user];
}
