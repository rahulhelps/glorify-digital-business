import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/network/data/models/downline_user_model.dart';

abstract class NetworkRepository {
  Future<List<UserModel>> getUplineChain(String startReferredBy);
  Future<List<DownlineUserModel>> getAllDownlines(String referCode);
  Future<(List<DownlineUserModel>, DocumentSnapshot?)> getPaginatedDownlines(
    String referCode, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  });
}
