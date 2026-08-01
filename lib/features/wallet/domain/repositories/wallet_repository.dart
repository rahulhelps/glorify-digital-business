import 'package:global_earn/features/auth/data/models/user_model.dart';

abstract class WalletRepository {
  Stream<UserModel> watchUserBalance(String uid);
}
