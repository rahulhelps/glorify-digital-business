import 'package:global_earn/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String emailOrPhone, String password);
  Future<UserModel> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? referredBy,
  });
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}
