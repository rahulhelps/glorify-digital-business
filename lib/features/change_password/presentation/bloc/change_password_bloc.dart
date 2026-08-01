import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/change_password/domain/repositories/change_password_repository.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final ChangePasswordRepository repository;

  ChangePasswordBloc({required this.repository})
    : super(ChangePasswordInitial()) {
    on<PasswordFieldChanged>(_onPasswordFieldChanged);
    on<SubmitChangePassword>(_onSubmitChangePassword);
  }

  void _onPasswordFieldChanged(
    PasswordFieldChanged event,
    Emitter<ChangePasswordState> emit,
  ) {
    final isMinLength = event.newPass.length >= 8;
    final isMatch = event.newPass == event.confirm && event.confirm.isNotEmpty;
    final canSubmit =
        event.current.isNotEmpty &&
        event.newPass.isNotEmpty &&
        isMinLength &&
        isMatch;

    if (canSubmit) {
      emit(
        ChangePasswordValid(
          isMinLength: isMinLength,
          isMatch: isMatch,
          canSubmit: true,
        ),
      );
    } else {
      emit(ChangePasswordInvalid(isMinLength: isMinLength, isMatch: isMatch));
    }
  }

  Future<void> _onSubmitChangePassword(
    SubmitChangePassword event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(ChangePasswordLoading());
    try {
      await repository.changePassword(
        currentPassword: event.current,
        newPassword: event.newPass,
      );

      // Fix 2: Add debug log and ensure emit is reached
      debugPrint('✅ [ChangePassword] Emitting success state');
      emit(ChangePasswordSuccess());
    } catch (e) {
      debugPrint('❌ [ChangePassword] Error: $e');
      emit(ChangePasswordError(e.toString()));

      // Re-emit validation state after error so button becomes active again
      final isMinLength = event.newPass.length >= 8;
      emit(
        ChangePasswordValid(
          isMinLength: isMinLength,
          isMatch: true, // Assume it was valid before submit
          canSubmit: true,
        ),
      );
    }
  }
}
