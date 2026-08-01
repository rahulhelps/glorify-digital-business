import 'package:flutter/foundation.dart';

@immutable
abstract class ChangePinState {}

class PinInitial extends ChangePinState {}

class PinLoading extends ChangePinState {}

class PinNotSet extends ChangePinState {}

class PinAlreadySet extends ChangePinState {}

class PinSuccess extends ChangePinState {
  final String message;
  PinSuccess(this.message);
}

class PinError extends ChangePinState {
  final String message;
  PinError(this.message);
}
