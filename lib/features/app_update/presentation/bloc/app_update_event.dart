import 'package:equatable/equatable.dart';

abstract class AppUpdateEvent extends Equatable {
  const AppUpdateEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the splash screen detects an internet connection.
/// Triggers a Firestore fetch → version comparison → state emission.
class CheckAppUpdate extends AppUpdateEvent {
  const CheckAppUpdate();
}
