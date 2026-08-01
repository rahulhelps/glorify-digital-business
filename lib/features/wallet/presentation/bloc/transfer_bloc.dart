import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/wallet/domain/repositories/transfer_repository.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';
import 'dart:developer' as dev;

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final TransferRepository repository;
  Timer? _searchDebounce;

  TransferBloc({required this.repository}) : super(const TransferState()) {
    on<SearchReceiver>((event, emit) async {
      _searchDebounce?.cancel();

      if (event.query.isEmpty) {
        emit(const TransferState());
        return;
      }

      final completer = Completer<void>();
      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
        if (!completer.isCompleted) completer.complete();
      });

      await completer.future;

      emit(const TransferState(status: TransferStatus.searching));

      try {
        final receiver = await repository.searchReceiver(event.query);

        if (receiver == null) {
          emit(const TransferState(status: TransferStatus.receiverNotFound));
        } else if (receiver.uid == event.currentUid) {
          dev.log('❌ [Transfer] Self transfer attempt');
          emit(const TransferState(status: TransferStatus.selfTransferError));
        } else {
          dev.log('✅ [Transfer] Receiver found: ${receiver.name}');
          emit(TransferState(status: TransferStatus.receiverFound, receiver: receiver));
        }
      } catch (e) {
        emit(const TransferState(status: TransferStatus.error, errorMessage: 'অনুসন্ধান করতে ত্রুটি হয়েছে।'));
      }
    });

    on<ClearSearch>((event, emit) {
      _searchDebounce?.cancel();
      emit(const TransferState());
    });

    on<SubmitTransfer>((event, emit) async {
      emit(state.copyWith(status: TransferStatus.loading));

      try {
        // Verify PIN
        dev.log('🔥 [Transfer] Verifying PIN...');
        final storedPin = await repository.getUserPin(event.sender.uid);

        if (storedPin == null || storedPin.isEmpty) {
          dev.log('❌ [Transfer] PIN not set');
          emit(state.copyWith(status: TransferStatus.pinNotSet));
          return;
        }

        if (storedPin != event.pin) {
          dev.log('❌ [Transfer] Wrong PIN');
          emit(state.copyWith(status: TransferStatus.error, errorMessage: 'ভুল পিন। আবার চেষ্টা করুন'));
          return;
        }

        dev.log('✅ [Transfer] PIN verified');

        // Perform transfer
        await repository.performTransfer(
          senderUid: event.sender.uid,
          receiverUid: event.receiver.uid,
          senderName: event.sender.name,
          receiverName: event.receiver.name,
          amount: event.amount,
        );

        emit(state.copyWith(
          status: TransferStatus.success,
          amount: event.amount,
          receiverName: event.receiver.name,
        ));
      } catch (e) {
        emit(state.copyWith(status: TransferStatus.error, errorMessage: e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
