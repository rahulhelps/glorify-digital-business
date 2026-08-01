import 'package:equatable/equatable.dart';

abstract class BonusEvent extends Equatable {
  const BonusEvent();
  @override
  List<Object?> get props => [];
}

class LoadBonusStatus extends BonusEvent {
  final String bonusType;
  const LoadBonusStatus(this.bonusType);
  @override
  List<Object?> get props => [bonusType];
}

class ClaimBonus extends BonusEvent {
  final String bonusType;
  final double amount;
  final String bonusName;
  final Map<String, dynamic>? extraClaimData;

  const ClaimBonus({
    required this.bonusType,
    required this.amount,
    required this.bonusName,
    this.extraClaimData,
  });

  @override
  List<Object?> get props => [bonusType, amount, bonusName];
}
