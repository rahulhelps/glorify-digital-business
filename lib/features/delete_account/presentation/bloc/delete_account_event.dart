import 'package:equatable/equatable.dart';

abstract class DeleteAccountEvent extends Equatable {
  const DeleteAccountEvent();

  @override
  List<Object> get props => [];
}

class ToggleConfirmation extends DeleteAccountEvent {
  final bool isConfirmed;
  const ToggleConfirmation(this.isConfirmed);

  @override
  List<Object> get props => [isConfirmed];
}

class SubmitDeleteAccount extends DeleteAccountEvent {
  final String password;
  const SubmitDeleteAccount(this.password);

  @override
  List<Object> get props => [password];
}

class DeleteAccountSubmitted
    extends DeleteAccountEvent {} // Added to fix widget error
