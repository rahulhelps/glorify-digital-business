import 'package:global_earn/features/network_team/domain/repositories/network_repository.dart';

class NetworkRepositoryImpl implements NetworkRepository {
  @override
  Future<void> updateNetworkTree(String newUserId, String referredBy) async {
    // Implemented in AuthRepositoryImpl to share a single WriteBatch with user creation.
  }
}
