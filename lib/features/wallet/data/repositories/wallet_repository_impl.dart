import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final FirebaseFirestore _firestore;

  WalletRepositoryImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Stream<UserModel> watchUserBalance(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('User not found');
      }
      final data = snapshot.data()!;
      return UserModel.fromJson(data);
    });
  }
}
