import 'package:equatable/equatable.dart';
import '../../domain/entities/filter_type.dart';

abstract class IncomeSummaryEvent extends Equatable {
  const IncomeSummaryEvent();

  @override
  List<Object?> get props => [];
}

class LoadIncomeDetail extends IncomeSummaryEvent {
  final FilterType filterType;

  const LoadIncomeDetail(this.filterType);

  @override
  List<Object?> get props => [filterType];
}
