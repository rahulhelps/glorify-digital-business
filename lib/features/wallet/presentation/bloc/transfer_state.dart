import 'package:global_earn/features/auth/data/models/user_model.dart';

enum TransferStatus {
  initial,
  searching,
  receiverFound,
  receiverNotFound,
  selfTransferError,
  loading,
  success,
  error,
  pinNotSet,
}

class TransferState {
  final UserModel? receiver;
  final String? errorMessage;
  final TransferStatus status;
  final double? amount;
  final String? receiverName;

  const TransferState({
    this.receiver,
    this.errorMessage,
    this.status = TransferStatus.initial,
    this.amount,
    this.receiverName,
  });

  TransferState copyWith({
    UserModel? receiver,
    String? errorMessage,
    TransferStatus? status,
    double? amount,
    String? receiverName,
  }) {
    return TransferState(
      receiver: receiver ?? this.receiver,
      errorMessage: errorMessage,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      receiverName: receiverName ?? this.receiverName,
    );
  }

  bool get isLoading => status == TransferStatus.loading;
}

