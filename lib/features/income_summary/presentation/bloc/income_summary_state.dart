import 'package:equatable/equatable.dart';
import '../../data/models/income_history_model.dart';
import '../../domain/entities/filter_type.dart';

abstract class IncomeSummaryState extends Equatable {
  const IncomeSummaryState();

  @override
  List<Object?> get props => [];
}

class IncomeSummaryInitial extends IncomeSummaryState {}

class IncomeSummaryLoading extends IncomeSummaryState {}

class IncomeSummaryLoaded extends IncomeSummaryState {
  final List<IncomeHistoryModel> transactions;
  final double totalAmount;
  final FilterType filterType;

  const IncomeSummaryLoaded({
    required this.transactions,
    required this.totalAmount,
    required this.filterType,
  });

  @override
  List<Object?> get props => [transactions, totalAmount, filterType];
}

class IncomeSummaryError extends IncomeSummaryState {
  final String message;
  const IncomeSummaryError(this.message);

  @override
  List<Object?> get props => [message];
}
