import 'package:global_earn/features/auth/data/models/user_model.dart';

abstract class TransferRepository {
  Future<UserModel?> searchReceiver(String query);
  Future<String?> getUserPin(String uid);
  Stream<List<Map<String, dynamic>>> watchTransferHistory(String uid);
  Future<double> getEarningBalance(String uid);
  Future<void> performTransfer({
    required String senderUid,
    required String receiverUid,
    required String senderName,
    required String receiverName,
    required double amount,
  });
}
