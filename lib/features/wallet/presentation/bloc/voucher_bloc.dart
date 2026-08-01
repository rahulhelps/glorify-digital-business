import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/wallet/domain/repositories/voucher_repository.dart';
import '../../data/models/voucher_history_model.dart';
import 'voucher_event.dart';
import 'voucher_state.dart';

class VoucherBloc extends Bloc<VoucherEvent, VoucherState> {
  final VoucherRepository voucherRepository;

  VoucherBloc({required this.voucherRepository}) : super(VoucherInitial()) {
    on<LoadVoucherHistory>(_onLoadVoucherHistory);
    on<PurchaseVoucher>(_onPurchaseVoucher);
    on<RedeemVoucher>(_onRedeemVoucher);
  }

  Future<void> _onLoadVoucherHistory(
    LoadVoucherHistory event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherLoading());
    await emit.forEach<List<VoucherHistoryModel>>(
      voucherRepository.getVoucherHistory(uid: event.uid, limit: event.limit),
      onData: (history) => VoucherLoaded(history),
      onError: (error, _) =>
          VoucherError(error.toString().replaceAll('Exception: ', '')),
    );
  }

  Future<void> _onPurchaseVoucher(
    PurchaseVoucher event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherLoading());
    try {
      final code = await voucherRepository.purchaseVoucher(
        uid: event.uid,
        amount: event.amount,
      );
      emit(VoucherSuccess('ভাউচার কেনা সফল হয়েছে', code: code));
    } catch (e) {
      emit(VoucherError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRedeemVoucher(
    RedeemVoucher event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherLoading());
    try {
      await voucherRepository.redeemVoucher(uid: event.uid, code: event.code);
      emit(const VoucherSuccess('ভাউচার সফলভাবে রিডিম হয়েছে!'));
    } catch (e) {
      emit(VoucherError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
