import 'package:equatable/equatable.dart';

abstract class TransferHistoryEvent extends Equatable {
  const TransferHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransferHistory extends TransferHistoryEvent {
  final String uid;
  const LoadTransferHistory(this.uid);

  @override
  List<Object?> get props => [uid];
}

class FilterByMonth extends TransferHistoryEvent {
  final DateTime month;
  const FilterByMonth(this.month);

  @override
  List<Object?> get props => [month];
}

class UpdateTransfers extends TransferHistoryEvent {
  final List<Map<String, dynamic>> transfers;
  const UpdateTransfers(this.transfers);

  @override
  List<Object?> get props => [transfers];
}

class HandleError extends TransferHistoryEvent {
  final String message;
  const HandleError(this.message);

  @override
  List<Object?> get props => [message];
}
