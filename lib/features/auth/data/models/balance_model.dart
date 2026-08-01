class BalanceModel {
  final num earning;
  final num referral;
  final num voucher;
  final num withdrawn;
  final num total;
  final num rechargeBalance;

  BalanceModel({
    required this.earning,
    required this.referral,
    required this.voucher,
    required this.withdrawn,
    required this.total,
    this.rechargeBalance = 0,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      earning: json['earning'] ?? 0,
      referral: json['referral'] ?? 0,
      voucher: json['voucher'] ?? 0,
      withdrawn: json['withdrawn'] ?? 0,
      total: json['total'] ?? 0,
      rechargeBalance: json['recharge_balance'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'earning': earning,
      'referral': referral,
      'voucher': voucher,
      'withdrawn': withdrawn,
      'total': total,
      'recharge_balance': rechargeBalance,
    };
  }
}
