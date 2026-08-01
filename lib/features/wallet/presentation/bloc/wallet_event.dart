import 'package:equatable/equatable.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class WalletStarted extends WalletEvent {
  const WalletStarted();
}

class WalletBalanceUpdated extends WalletEvent {
  final UserModel user;

  const WalletBalanceUpdated(this.user);

  @override
  List<Object?> get props => [user];
}
