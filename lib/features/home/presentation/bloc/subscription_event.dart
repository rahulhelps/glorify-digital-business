import 'package:equatable/equatable.dart';
import 'package:quick_payment/quick_payment.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscriptionStatus extends SubscriptionEvent {
  final String uid;
  const LoadSubscriptionStatus(this.uid);

  @override
  List<Object?> get props => [uid];
}

class PaymentSubmitted extends SubscriptionEvent {
  final String uid;
  final String userName;
  final String userEmail;
  final PaymentData data;
  final String requestedPlan;

  const PaymentSubmitted({
    required this.uid,
    required this.userName,
    required this.userEmail,
    required this.data,
    required this.requestedPlan,
  });

  @override
  List<Object?> get props => [uid, userName, userEmail, data, requestedPlan];
}

class MonitorSubscriptionStatus extends SubscriptionEvent {
  final String uid;
  const MonitorSubscriptionStatus(this.uid);

  @override
  List<Object?> get props => [uid];
}

class SubscriptionStatusChanged extends SubscriptionEvent {
  final String status;
  const SubscriptionStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class AutoPaymentRequested extends SubscriptionEvent {
  final String uid;
  final String plan; // "plan320" — no underscore, matches PHP backend exactly
  const AutoPaymentRequested({required this.uid, required this.plan});

  @override
  List<Object?> get props => [uid, plan];
}
