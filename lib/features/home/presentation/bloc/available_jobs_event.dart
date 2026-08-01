import 'package:equatable/equatable.dart';

abstract class AvailableJobsEvent extends Equatable {
  const AvailableJobsEvent();
  @override
  List<Object?> get props => [];
}

class FetchAvailableJobs extends AvailableJobsEvent {}
