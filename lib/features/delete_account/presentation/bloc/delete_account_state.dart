import 'package:equatable/equatable.dart';

enum DeleteAccountStatus { initial, loading, success, error }

class DeleteAccountState extends Equatable {
  final DeleteAccountStatus status;
  final String message;
  final bool isConfirmed;

  const DeleteAccountState({
    this.status = DeleteAccountStatus.initial,
    this.message = '',
    this.isConfirmed = false,
  });

  bool get isSubmitting => status == DeleteAccountStatus.loading;
  bool get isSuccess => status == DeleteAccountStatus.success;

  DeleteAccountState copyWith({
    DeleteAccountStatus? status,
    String? message,
    bool? isConfirmed,
  }) {
    return DeleteAccountState(
      status: status ?? this.status,
      message: message ?? this.message,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  @override
  List<Object?> get props => [status, message, isConfirmed];
}
