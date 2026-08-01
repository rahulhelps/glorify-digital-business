import 'package:equatable/equatable.dart';
import 'package:global_earn/features/wallet/data/models/voucher_history_model.dart';

abstract class VoucherState extends Equatable {
  const VoucherState();
  @override
  List<Object?> get props => [];
}

class VoucherInitial extends VoucherState {}

class VoucherLoading extends VoucherState {}

class VoucherLoaded extends VoucherState {
  final List<VoucherHistoryModel> history;
  const VoucherLoaded(this.history);
  @override
  List<Object?> get props => [history];
}

class VoucherError extends VoucherState {
  final String message;
  const VoucherError(this.message);
  @override
  List<Object?> get props => [message];
}

class VoucherSuccess extends VoucherState {
  final String message;
  final String? code;
  const VoucherSuccess(this.message, {this.code});
  @override
  List<Object?> get props => [message, code];
}
