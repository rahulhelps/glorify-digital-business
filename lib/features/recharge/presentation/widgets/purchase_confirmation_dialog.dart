import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class PurchaseConfirmationDialog extends StatefulWidget {
  final String uid;
  final String packageDetails;
  final String operator;
  final double offerPrice;
  final double regularPrice;
  final VoidCallback onSuccess;

  const PurchaseConfirmationDialog({
    super.key,
    required this.uid,
    required this.packageDetails,
    required this.operator,
    required this.offerPrice,
    required this.regularPrice,
    required this.onSuccess,
  });

  @override
  State<PurchaseConfirmationDialog> createState() => _PurchaseConfirmationDialogState();
}

class _PurchaseConfirmationDialogState extends State<PurchaseConfirmationDialog> {
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitPurchase() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 11) {
      setState(() => _errorMessage = 'সঠিক মোবাইল নম্বর প্রদান করুন');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final batch = FirebaseFirestore.instance.batch();
      
      // 1. Save request
      final requestRef = FirebaseFirestore.instance.collection('drive_requests').doc();
      batch.set(requestRef, {
        'userId': widget.uid,
        'packageDetails': widget.packageDetails,
        'operator': widget.operator,
        'offerPrice': widget.offerPrice,
        'targetNumber': phone,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Deduct balance
      final userRef = FirebaseFirestore.instance.collection('users').doc(widget.uid);
      batch.update(userRef, {
        'balance.earning': FieldValue.increment(-widget.offerPrice),
        'balance.total': FieldValue.increment(-widget.offerPrice),
      });

      await batch.commit();

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess();
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'অফার ক্রয় করতে সমস্যা হয়েছে। আবার চেষ্টা করুন।';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ড্রাইভ অফার ক্রয় নিশ্চিতকরণ',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.operator.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.packageDetails,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'অফার মূল্য: ৳${widget.offerPrice.toInt()}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'নিয়মিত: ৳${widget.regularPrice.toInt()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.phone_android, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Text(
                  'অফারটি চালু করার মোবাইল নম্বর',
                  style: TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              style: TextStyle(color: Colors.black),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '01XXXXXXXXX',
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                errorText: _errorMessage,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'ক্রয় নিশ্চিত করুন',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
