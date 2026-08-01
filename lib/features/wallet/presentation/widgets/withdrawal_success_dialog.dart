import 'package:flutter/material.dart';

class WithdrawalSuccessDialog extends StatelessWidget {
  final double amount;
  final String paymentMethod;
  final String userPhone;
  final DateTime dateTime;

  const WithdrawalSuccessDialog({
    super.key,
    required this.amount,
    required this.paymentMethod,
    required this.userPhone,
    required this.dateTime,
  });

  String _formatDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi:$s';
  }

  String _maskPhone(String phone) {
    if (phone.isEmpty) return '';
    if (phone.length <= 4) return phone;
    final visible = phone.substring(0, 4);
    final hidden = '*' * (phone.length - 4);
    return visible + hidden;
  }

  @override
  Widget build(BuildContext context) {
    final formattedDateTime = _formatDateTime(dateTime);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── TOP SECTION: Blue gradient + check icon ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'উইথড্র রিকুয়েস্ট সফল হয়েছে!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  '২৪ ঘণ্টার মধ্যে প্রসেস করা হবে।',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // ── BOTTOM SECTION: Details ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _detailRow('উইথড্র এর পরিমাণ', '৳${amount.toStringAsFixed(2)}'),
                _divider(),
                _detailRow('উইথড্র এর ধরণ', paymentMethod),
                _divider(),
                _detailRow('মোবাইল নম্বর', _maskPhone(userPhone)),
                _divider(),
                _detailRow('তারিখ এবং সময়', formattedDateTime),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ঠিক আছে',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: Colors.grey[200],
    );
  }
}
