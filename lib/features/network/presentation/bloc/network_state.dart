import 'package:equatable/equatable.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';

abstract class NetworkState extends Equatable {
  const NetworkState();

  @override
  List<Object?> get props => [];
}

class NetworkInitial extends NetworkState {
  const NetworkInitial();
}

class NetworkLoading extends NetworkState {
  const NetworkLoading();
}

class NetworkReady extends NetworkState {
  final UserModel user;
  final num totalTeam;

  const NetworkReady({required this.user, required this.totalTeam});

  @override
  List<Object?> get props => [user, totalTeam];
}

class NetworkError extends NetworkState {
  final String message;
  const NetworkError(this.message);

  @override
  List<Object?> get props => [message];
}
