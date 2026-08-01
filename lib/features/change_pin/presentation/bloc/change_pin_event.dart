import 'package:flutter/foundation.dart';

@immutable
abstract class ChangePinEvent {}

class LoadPinStatus extends ChangePinEvent {
  final String uid;
  LoadPinStatus(this.uid);
}

class SetPin extends ChangePinEvent {
  final String uid;
  final String newPin;
  SetPin({required this.uid, required this.newPin});
}

class ChangePin extends ChangePinEvent {
  final String uid;
  final String currentPin;
  final String newPin;
  ChangePin({
    required this.uid,
    required this.currentPin,
    required this.newPin,
  });
}

// Legacy events to support ChangePinNumpad compilation
class PinDigitPressed extends ChangePinEvent {
  final String digit;
  PinDigitPressed(this.digit);
}

class PinBackspacePressed extends ChangePinEvent {}
