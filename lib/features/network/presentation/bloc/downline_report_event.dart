import 'package:equatable/equatable.dart';

abstract class DownlineReportEvent extends Equatable {
  const DownlineReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadDownlines extends DownlineReportEvent {
  final String referCode;

  const LoadDownlines(this.referCode);

  @override
  List<Object?> get props => [referCode];
}

class FilterDownlines extends DownlineReportEvent {
  final String filter; // 'all' | 'premium' | 'normal'

  const FilterDownlines(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SearchDownlines extends DownlineReportEvent {
  final String query;

  const SearchDownlines(this.query);

  @override
  List<Object?> get props => [query];
}
