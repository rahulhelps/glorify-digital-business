import 'package:equatable/equatable.dart';
import '../../data/models/micro_job_model.dart';

abstract class AvailableJobsState extends Equatable {
  const AvailableJobsState();
  @override
  List<Object?> get props => [];
}

class AvailableJobsInitial extends AvailableJobsState {}

class AvailableJobsLoading extends AvailableJobsState {}

class AvailableJobsLoaded extends AvailableJobsState {
  final List<MicroJobModel> jobs;
  const AvailableJobsLoaded(this.jobs);
  @override
  List<Object?> get props => [jobs];
}

class AvailableJobsFailure extends AvailableJobsState {
  final String message;
  const AvailableJobsFailure(this.message);
  @override
  List<Object?> get props => [message];
}
