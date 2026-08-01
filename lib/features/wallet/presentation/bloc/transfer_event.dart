import 'package:global_earn/features/auth/data/models/user_model.dart';

abstract class TransferEvent {}

class SearchReceiver extends TransferEvent {
  final String query;
  final String currentUid;
  SearchReceiver(this.query, this.currentUid);
}

class ClearSearch extends TransferEvent {}

class SubmitTransfer extends TransferEvent {
  final double amount;
  final String pin;
  final UserModel sender;
  final UserModel receiver;

  SubmitTransfer({
    required this.amount,
    required this.pin,
    required this.sender,
    required this.receiver,
  });
}
