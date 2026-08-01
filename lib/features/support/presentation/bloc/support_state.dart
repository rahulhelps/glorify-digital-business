import 'package:equatable/equatable.dart';
import 'package:global_earn/features/support/data/models/support_settings_model.dart';

abstract class SupportState extends Equatable {
  const SupportState();

  @override
  List<Object?> get props => [];
}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class SupportLoaded extends SupportState {
  final SupportSettingsModel data;

  const SupportLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class SupportNoInternet extends SupportState {}

class SupportError extends SupportState {
  final String message;

  const SupportError({required this.message});

  @override
  List<Object?> get props => [message];
}