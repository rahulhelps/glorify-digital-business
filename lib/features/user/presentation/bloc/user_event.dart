import 'package:equatable/equatable.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object> get props => [];
}

class UserLoadedEvent extends UserEvent {
  final UserModel user;
  const UserLoadedEvent(this.user);
  @override
  List<Object> get props => [user];
}

class UserClearedEvent extends UserEvent {}
