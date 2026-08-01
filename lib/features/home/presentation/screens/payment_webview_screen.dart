import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/features/home/presentation/screens/home_screen.dart';

/// PaymentWebViewScreen — displays the ZiniPay payment gateway in a WebView.
///
/// Success detection: listens directly to
/// `payment_invoices/{invoiceId}` in Firestore, which transitions from
/// 'pending' → 'completed' exactly once per payment attempt.  This avoids the
/// Bloc/Equatable dedup problem where re-emitting SubscriptionActive is silently
/// dropped when the user's subscription was already active.
class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String invoiceCollectionPath;

  const PaymentWebViewScreen({
    super.key, 
    required this.paymentUrl,
    required this.invoiceCollectionPath,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isProcessing = false;
  bool _showTimeout = false;

  // Timeout timer — still useful if the webhook never fires (server-side issue)
  Timer? _timeoutTimer;

  // Firestore snapshot subscription for this specific payment
  StreamSubscription<DocumentSnapshot>? _invoiceSubscription;

  // Parsed from widget.paymentUrl — last path segment
  String? _invoiceId;

  // AppBar color matching the plan screen
  static const Color _primaryBlue = Color(0xFF0F3D88);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    // Extract invoiceId: last non-empty path segment of the payment URL
    // e.g. "https://secure.zinipay.com/golden-power/payment/{invoiceId}"
    _invoiceId = _parseInvoiceId(widget.paymentUrl);

    _controller = WebViewController()
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (!_isProcessing) {
              setState(() => _isLoading = true);
            }
            // Detect navigation to the verify.php success/callback page
            if (_isPaymentVerifyUrl(url)) {
              if (mounted) {
                setState(() {
                  _isProcessing = true;
                  _isLoading = false;
                });

                // Start 45-second timeout fallback
                _timeoutTimer?.cancel();
                _timeoutTimer = Timer(const Duration(seconds: 45), () {
                  if (mounted) {
                    setState(() => _showTimeout = true);
                  }
                });

                // Start listening to THIS payment's Firestore document
                _startInvoiceListener();
              }
            }
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _invoiceSubscription?.cancel();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Extracts the invoiceId from the ZiniPay payment URL.
  /// Returns null if the URL is malformed.
  static String? _parseInvoiceId(String url) {
    try {
      final segments = Uri.parse(url).pathSegments;
      // Last non-empty segment is the invoiceId
      for (int i = segments.length - 1; i >= 0; i--) {
        if (segments[i].isNotEmpty) return segments[i];
      }
    } catch (_) {}
    return null;
  }

  /// Returns true if the URL is the ZiniPay verify.php callback page.
  bool _isPaymentVerifyUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.contains('goldenpowerbd.shop') &&
          uri.path.startsWith('/payment/verify.php');
    } catch (_) {
      return false;
    }
  }

  /// Starts a Firestore snapshot listener on `payment_invoices/{invoiceId}`.
  /// Fires reliably for every status change, including when subscription was
  /// already active (bypasses the Bloc Equatable dedup issue entirely).
  void _startInvoiceListener() {
    if (_invoiceId == null) return;

    _invoiceSubscription?.cancel();
    _invoiceSubscription = FirebaseFirestore.instance
        .doc('${widget.invoiceCollectionPath}/$_invoiceId')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;

      final status = snapshot.data()?['status'] as String?;

      if (status == 'completed') {
        _timeoutTimer?.cancel();
        _invoiceSubscription?.cancel();
        // Pop the entire imperative stack (WebView + VerificationPlanScreen),
        // then tell GoRouter to display '/home' on the now-visible shell.
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.isFirst);
        if (mounted) context.go('/home');
      } else if (status == 'failed' || status == 'cancelled') {
        _timeoutTimer?.cancel();
        _invoiceSubscription?.cancel();
        setState(() {
          _isProcessing = false;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'পেমেন্ট সম্পন্ন হয়নি। আবার চেষ্টা করুন।',
              ),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 4),
            ),
          );
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
      // 'pending' or any other status → keep waiting
    }, onError: (_) {
      // Firestore error — let the 45-second timeout handle it
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isProcessing,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'পেমেন্ট',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          centerTitle: true,
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: _isProcessing
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                ),
        ),
        body: _isProcessing
            ? _buildProcessingState()
            : Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: _primaryBlue,
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildProcessingState() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_showTimeout) ...[
            const CircularProgressIndicator(color: _primaryBlue),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'পেমেন্ট যাচাই করা হচ্ছে, অনুগ্রহ করে অপেক্ষা করুন...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            const Icon(Icons.info_outline, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'যাচাইকরণে সময় লাগছে। কিছুক্ষণ পর আবার চেক করুন।',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _invoiceSubscription?.cancel();
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('হোমে যান', style: TextStyle(fontSize: 16)),
            ),
          ],
        ],
      ),
    );
  }
}
