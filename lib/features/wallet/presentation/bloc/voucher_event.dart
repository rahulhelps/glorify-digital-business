import 'package:equatable/equatable.dart';

abstract class VoucherEvent extends Equatable {
  const VoucherEvent();
  @override
  List<Object?> get props => [];
}

class LoadVoucherHistory extends VoucherEvent {
  final String uid;
  final int? limit;
  const LoadVoucherHistory({required this.uid, this.limit});
  @override
  List<Object?> get props => [uid, limit];
}

class PurchaseVoucher extends VoucherEvent {
  final String uid;
  final num amount;
  const PurchaseVoucher({required this.uid, required this.amount});
  @override
  List<Object?> get props => [uid, amount];
}

class RedeemVoucher extends VoucherEvent {
  final String uid;
  final String code;
  const RedeemVoucher({required this.uid, required this.code});
  @override
  List<Object?> get props => [uid, code];
}
