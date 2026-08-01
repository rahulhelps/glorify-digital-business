import 'package:equatable/equatable.dart';

abstract class AppUpdateState extends Equatable {
  const AppUpdateState();

  @override
  List<Object?> get props => [];
}

/// Default state before any check has been triggered.
class AppUpdateInitial extends AppUpdateState {
  const AppUpdateInitial();
}

/// Actively fetching version data from Firestore.
class AppUpdateChecking extends AppUpdateState {
  const AppUpdateChecking();
}

/// Local version is equal to or greater than remote — proceed normally.
class AppUpdateUpToDate extends AppUpdateState {
  const AppUpdateUpToDate();
}

/// Local version is behind remote — lock the user with a mandatory update dialog.
class AppUpdateRequired extends AppUpdateState {
  /// The Play Store or APK download URL from Firestore `download_url` field.
  final String downloadUrl;

  const AppUpdateRequired({required this.downloadUrl});

  @override
  List<Object?> get props => [downloadUrl];
}

/// Firestore fetch failed (network timeout, missing doc, permission error).
/// The caller should fail-open and let the user proceed.
class AppUpdateError extends AppUpdateState {
  final String message;

  const AppUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}
