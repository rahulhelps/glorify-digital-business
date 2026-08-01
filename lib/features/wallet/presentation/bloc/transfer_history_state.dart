import 'package:equatable/equatable.dart';

abstract class TransferHistoryState extends Equatable {
  const TransferHistoryState();

  @override
  List<Object?> get props => [];
}

class TransferHistoryInitial extends TransferHistoryState {}

class TransferHistoryLoading extends TransferHistoryState {}

class TransferHistoryLoaded extends TransferHistoryState {
  final List<Map<String, dynamic>> transfers;
  final double totalInflow;
  final double totalOutflow;
  final DateTime selectedMonth;

  const TransferHistoryLoaded({
    required this.transfers,
    required this.totalInflow,
    required this.totalOutflow,
    required this.selectedMonth,
  });

  @override
  List<Object?> get props => [
    transfers,
    totalInflow,
    totalOutflow,
    selectedMonth,
  ];
}

class TransferHistoryError extends TransferHistoryState {
  final String message;
  const TransferHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
