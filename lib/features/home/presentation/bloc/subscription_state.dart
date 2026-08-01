import 'package:equatable/equatable.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionNotSubscribed extends SubscriptionState {}

class SubscriptionPending extends SubscriptionState {}

class SubscriptionPaymentSuccess extends SubscriptionState {
  const SubscriptionPaymentSuccess();
}

class SubscriptionActive extends SubscriptionState {}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

class AutoPaymentLoading extends SubscriptionState {}

class AutoPaymentUrlReady extends SubscriptionState {
  final String paymentUrl;
  const AutoPaymentUrlReady(this.paymentUrl);

  @override
  List<Object?> get props => [paymentUrl];
}

class AutoPaymentError extends SubscriptionState {
  final String message;
  const AutoPaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
