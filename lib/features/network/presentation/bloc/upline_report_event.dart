import 'package:equatable/equatable.dart';

abstract class UplineReportEvent extends Equatable {
  const UplineReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadUplineReport extends UplineReportEvent {
  final String referredBy;

  const LoadUplineReport(this.referredBy);

  @override
  List<Object?> get props => [referredBy];
}
