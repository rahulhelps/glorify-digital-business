import 'package:equatable/equatable.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';

abstract class UplineReportState extends Equatable {
  const UplineReportState();

  @override
  List<Object?> get props => [];
}

class UplineReportInitial extends UplineReportState {}

class UplineReportLoading extends UplineReportState {}

class UplineReportLoaded extends UplineReportState {
  final List<UserModel> uplines;

  const UplineReportLoaded(this.uplines);

  @override
  List<Object?> get props => [uplines];
}

class UplineReportError extends UplineReportState {
  final String message;

  const UplineReportError(this.message);

  @override
  List<Object?> get props => [message];
}
