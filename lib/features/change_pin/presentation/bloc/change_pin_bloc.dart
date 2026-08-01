import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/change_pin/domain/repositories/pin_repository.dart';
import 'change_pin_event.dart';
import 'change_pin_state.dart';
import 'dart:developer' as dev;

class ChangePinBloc extends Bloc<ChangePinEvent, ChangePinState> {
  final PinRepository repository;

  ChangePinBloc({required this.repository}) : super(PinInitial()) {
    on<LoadPinStatus>((event, emit) async {
      emit(PinLoading());
      try {
        dev.log('🔥 [PIN] Checking pin status for uid: ${event.uid}');
        final pin = await repository.getPinStatus(event.uid);
        if (pin == null || pin.isEmpty) {
          dev.log('✅ [PIN] Pin not set — showing set UI');
          emit(PinNotSet());
        } else {
          dev.log('✅ [PIN] Pin exists — showing change UI');
          emit(PinAlreadySet());
        }
      } catch (e) {
        emit(PinError(e.toString()));
      }
    });

    on<SetPin>((event, emit) async {
      emit(PinLoading());
      try {
        await repository.setPin(event.uid, event.newPin);
        emit(PinSuccess('পিন সফলভাবে সেট হয়েছে'));
      } catch (e) {
        emit(PinError(e.toString()));
      }
    });

    on<ChangePin>((event, emit) async {
      emit(PinLoading());
      try {
        await repository.changePin(event.uid, event.currentPin, event.newPin);
        emit(PinSuccess('পিন সফলভাবে পরিবর্তন হয়েছে'));
      } catch (e) {
        emit(PinError(e.toString()));
      }
    });

    // Legacy handlers to support ChangePinNumpad compilation
    on<PinDigitPressed>((event, emit) {});
    on<PinBackspacePressed>((event, emit) {});
  }
}
