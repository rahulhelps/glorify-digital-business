import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/features/app_update/domain/repositories/app_update_repository.dart';

class AppUpdateRepositoryImpl implements AppUpdateRepository {
  final FirebaseFirestore _firestore;

  const AppUpdateRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<Map<String, dynamic>> fetchVersionControl() async {
    final doc = await _firestore
        .collection('app_config')
        .doc('version_control')
        .get(const GetOptions(source: Source.server));

    if (!doc.exists || doc.data() == null) {
      throw Exception(
        'version_control document not found at app_config/version_control',
      );
    }

    final data = doc.data()!;
    return {
      'latest_version': (data['latest_version']?.toString() ?? data['currentVersion']?.toString() ?? '1').trim(),
      'download_url': (data['download_url'] as String? ?? '').trim(),
      'isForceUpdate': data['isForceUpdate'] as bool? ?? data['is_force_update'] as bool? ?? true,
    };
  }
}
