import 'package:equatable/equatable.dart';

abstract class BonusState extends Equatable {
  const BonusState();
  @override
  List<Object?> get props => [];
}

class BonusInitial extends BonusState {}

class BonusLoading extends BonusState {}

class BonusLoaded extends BonusState {
  final Map<String, dynamic> data;
  const BonusLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class BonusClaimed extends BonusState {
  final String bonusType;
  const BonusClaimed(this.bonusType);
  @override
  List<Object?> get props => [bonusType];
}

class BonusError extends BonusState {
  final String message;
  const BonusError(this.message);
  @override
  List<Object?> get props => [message];
}
