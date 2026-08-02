import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:global_earn/features/auth/domain/repositories/auth_repository.dart';
import 'package:global_earn/features/home/domain/repositories/subscription_repository.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_event.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';
import 'dart:developer' as dev;

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _subscriptionRepository;
  final AuthRepository _authRepository;
  final UserBloc _userBloc;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscriptionSub;

  SubscriptionBloc({
    required SubscriptionRepository subscriptionRepository,
    required AuthRepository authRepository,
    required UserBloc userBloc,
  })  : _subscriptionRepository = subscriptionRepository,
        _authRepository = authRepository,
        _userBloc = userBloc,
        super(SubscriptionInitial()) {
    on<LoadSubscriptionStatus>(_onLoadStatus);
    on<PaymentSubmitted>(_onPaymentSubmitted);
    on<MonitorSubscriptionStatus>(_onMonitorStatus);
    on<SubscriptionStatusChanged>(_onStatusChanged);
    on<AutoPaymentRequested>(_onAutoPaymentRequested);
  }

  Future<void> _refreshUser() async {
    try {
      final updatedUser = await _authRepository.getCurrentUser();
      if (updatedUser != null) {
        _userBloc.add(UserLoadedEvent(updatedUser));
      }
    } catch (e) {
      dev.log('❌ [Subscription] User refresh error: $e', name: 'Subscription');
    }
  }

  Future<void> _onLoadStatus(
    LoadSubscriptionStatus event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final status = await _subscriptionRepository.checkPendingRequest(
        event.uid,
      );
      if (status == 'pending') {
        emit(SubscriptionPending());
      } else {
        emit(SubscriptionNotSubscribed());
      }

      add(MonitorSubscriptionStatus(event.uid));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onPaymentSubmitted(
    PaymentSubmitted event,
    Emitter<SubscriptionState> emit,
  ) async {
    /* ═══ OLD MANUAL PAYMENT SYSTEM — DISABLED as of 2026-07-21.
       Replaced by automatic ZiniPay flow (see AutoPaymentRequested below).
       Do NOT delete this code — kept for reference / rollback capability. ═══

    try {
      double amount;
      String transactionId;
      String method;
      DateTime submittedAt;

      try {
        final rawAmount = event.data.amount;
        amount = rawAmount is num
            ? rawAmount.toDouble()
            : double.tryParse('$rawAmount') ?? 0;
        transactionId = event.data.transactionId.toString().trim();
        method = event.data.method.toString();
        submittedAt = event.data.time;
      } catch (e) {
        dev.log('❌ [Subscription] Payment data parse error: $e', name: 'Subscription');
        emit(const SubscriptionError('পেমেন্ট তথ্য পড়া যায়নি। আবার চেষ্টা করুন।'));
        return;
      }

      if (transactionId.isEmpty) {
        emit(const SubscriptionError('ট্রানজেকশন আইডি প্রয়োজন।'));
        return;
      }

      if (event.requestedPlan != 'plan_320') {
        emit(const SubscriptionError('অবৈধ প্ল্যান নির্বাচন।'));
        return;
      }

      await _subscriptionRepository
          .savePaymentRequest(
            uid: event.uid,
            userName: event.userName,
            userEmail: event.userEmail,
            amount: amount,
            requestedPlan: event.requestedPlan,
            method: method,
            transactionId: transactionId,
            submittedAt: submittedAt,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              dev.log(
                '⏱ [Subscription] savePaymentRequest timed out after 30s',
                name: 'Subscription',
              );
              throw Exception('Request timed out. Please check your connection.');
            },
          );

      await _refreshUser();
      add(MonitorSubscriptionStatus(event.uid));
      emit(const SubscriptionPaymentSuccess());
      emit(SubscriptionPending());
    } catch (e) {
      dev.log('❌ [Subscription] _onPaymentSubmitted error: $e', name: 'Subscription');
      emit(SubscriptionError(e.toString()));
    }

    */
    emit(const SubscriptionError('This payment method is currently disabled. Please use automatic payment.'));
  }

  Future<void> _onAutoPaymentRequested(
    AutoPaymentRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(AutoPaymentLoading());
    try {
      final response = await http
          .post(
            Uri.parse('https://glorify-digital-business.shop/payment/create.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'uid': event.uid, 'plan': event.plan}),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['paymentUrl'] != null) {
        emit(AutoPaymentUrlReady(data['paymentUrl'] as String));
      } else {
        emit(AutoPaymentError(
          data['error']?.toString() ?? 'পেমেন্ট শুরু করা যায়নি। আবার চেষ্টা করুন।',
        ));
      }
    } catch (e) {
      dev.log('❌ [Subscription] AutoPayment error: $e', name: 'Subscription');
      emit(const AutoPaymentError('নেটওয়ার্ক সমস্যা। আবার চেষ্টা করুন।'));
    }
  }

  void _onMonitorStatus(
    MonitorSubscriptionStatus event,
    Emitter<SubscriptionState> emit,
  ) {
    _subscriptionSub?.cancel();
    _subscriptionSub = _firestore
        .collection('users')
        .doc(event.uid)
        .snapshots()
        .listen((doc) {
          if (doc.exists) {
            final status =
                doc.data()?['subscriptionStatus'] as String? ?? 'none';
            dev.log(
              '🔥 [Subscription] Status changed: $status',
              name: 'Subscription',
            );
            add(SubscriptionStatusChanged(status));
          }
        });
  }

  void _onStatusChanged(
    SubscriptionStatusChanged event,
    Emitter<SubscriptionState> emit,
  ) {
    switch (event.status) {
      case 'plan_320':
      case '320':
        emit(SubscriptionActive());
        _refreshUser();
        break;
      case 'pending':
        emit(SubscriptionPending());
        _refreshUser();
        break;
      case 'none':
      default:
        emit(SubscriptionNotSubscribed());
        _refreshUser();
        break;
    }
  }

  @override
  Future<void> close() {
    _subscriptionSub?.cancel();
    return super.close();
  }
}
