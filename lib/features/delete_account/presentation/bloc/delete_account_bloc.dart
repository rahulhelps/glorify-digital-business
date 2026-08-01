import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/delete_account/domain/repositories/delete_account_repository.dart';
import 'delete_account_event.dart';
import 'delete_account_state.dart';

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  final DeleteAccountRepository repository;

  DeleteAccountBloc({required this.repository})
    : super(const DeleteAccountState()) {
    on<ToggleConfirmation>(_onToggleConfirmation);
    on<SubmitDeleteAccount>(_onSubmitDeleteAccount);
  }

  void _onToggleConfirmation(
    ToggleConfirmation event,
    Emitter<DeleteAccountState> emit,
  ) {
    emit(state.copyWith(isConfirmed: event.isConfirmed));
  }

  Future<void> _onSubmitDeleteAccount(
    SubmitDeleteAccount event,
    Emitter<DeleteAccountState> emit,
  ) async {
    emit(state.copyWith(status: DeleteAccountStatus.loading));
    try {
      await repository.deleteAccount(password: event.password);
      emit(state.copyWith(status: DeleteAccountStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: DeleteAccountStatus.error,
          message: e.toString(),
        ),
      );
    }
  }
}
