import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:global_earn/features/app_update/domain/repositories/app_update_repository.dart';
import 'app_update_event.dart';
import 'app_update_state.dart';

class AppUpdateBloc extends Bloc<AppUpdateEvent, AppUpdateState> {
  final AppUpdateRepository _repository;

  AppUpdateBloc({required AppUpdateRepository repository})
      : _repository = repository,
        super(const AppUpdateInitial()) {
    on<CheckAppUpdate>(_onCheckAppUpdate);
  }

  Future<void> _onCheckAppUpdate(
    CheckAppUpdate event,
    Emitter<AppUpdateState> emit,
  ) async {
    emit(const AppUpdateChecking());

    try {
      // ── 1. Fetch local build number ─────────────────────────────────────────
      WidgetsFlutterBinding.ensureInitialized();
      final packageInfo = await PackageInfo.fromPlatform();
      final localBuild = int.tryParse(packageInfo.buildNumber) ?? 1;

      // ── 2. Fetch remote build number from Firestore ─────────────────────────
      final data = await _repository.fetchVersionControl();
      final backendBuild = int.tryParse(data['latest_version']?.toString() ?? '1') ?? 1;
      final downloadUrl = data['download_url'] as String? ?? '';
      final isForceUpdate = data['isForceUpdate'] as bool? ?? true;

      debugPrint(
        '[AppUpdateBloc] localBuild=$localBuild  backendBuild=$backendBuild isForceUpdate=$isForceUpdate',
      );

      // ── 3. Compare build numbers ────────────────────────────────────────────
      if (localBuild < backendBuild && isForceUpdate) {
        emit(AppUpdateRequired(downloadUrl: downloadUrl));
      } else {
        // Do NOT show dialog, proceed to dashboard safely
        emit(const AppUpdateUpToDate());
      }
    } catch (e) {
      debugPrint('[AppUpdateBloc] Version check failed: $e');
      // Fail-open: don't punish users for Firestore errors (missing doc,
      // permission issues, cold-start timeouts). Let them through.
      emit(AppUpdateError(message: e.toString()));
    }
  }
}
