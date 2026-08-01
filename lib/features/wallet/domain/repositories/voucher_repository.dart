import 'package:global_earn/features/wallet/data/models/voucher_history_model.dart';
import 'package:global_earn/features/wallet/data/models/voucher_model.dart';

abstract class VoucherRepository {
  Future<String> purchaseVoucher({required String uid, required num amount});
  Future<void> redeemVoucher({required String uid, required String code});
  Stream<List<VoucherHistoryModel>> getVoucherHistory({
    required String uid,
    String? type,
    int? limit,
  });
  Stream<List<VoucherModel>> getMyPurchasedVouchers(String uid);
}
