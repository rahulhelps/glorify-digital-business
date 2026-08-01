import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/auth/domain/repositories/auth_repository.dart';
import 'package:global_earn/features/recharge/domain/repositories/recharge_repository.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_event.dart';
import 'recharge_event.dart';
import 'recharge_state.dart';

class RechargeBloc extends Bloc<RechargeEvent, RechargeState> {
  final RechargeRepository repository;
  final AuthRepository authRepository;
  final UserBloc userBloc;
  bool _isSubmittingRequest = false;

  RechargeBloc({
    required this.repository,
    required this.authRepository,
    required this.userBloc,
  }) : super(const RechargeInitial()) {
    on<WatchRechargeBalance>(_onWatchBalance);
    on<SubmitRechargeRequest>(_onSubmitRequest);
    on<TransferFromWallet>(_onTransferFromWallet);
  }

  Future<void> _refreshUser() async {
    try {
      final updatedUser = await authRepository.getCurrentUser();
      if (updatedUser != null) {
        userBloc.add(UserLoadedEvent(updatedUser));
      }
    } catch (e) {
      dev.log('❌ [RechargeBloc] User refresh error: $e');
    }
  }

  Future<void> _onWatchBalance(
    WatchRechargeBalance event,
    Emitter<RechargeState> emit,
  ) async {
    await emit.forEach<double>(
      repository.watchRechargeBalance(event.uid),
      onData: (balance) {
        if (_isSubmittingRequest) return const RechargeSubmitting();
        return RechargeBalanceLoaded(balance);
      },
      onError: (e, _) {
        dev.log('❌ [RechargeBloc] Balance watch error: $e');
        return const RechargeError('ব্যালেন্স লোড হয়নি');
      },
    );
  }

  bool _isOperatorPrefixValid(String operator, String prefix) {
    switch (operator.toLowerCase()) {
      case 'grameenphone':
      case 'gp':
        return prefix == '017' || prefix == '013';
      case 'robi':
        return prefix == '018';
      case 'airtel':
        return prefix == '016';
      case 'banglalink':
        return prefix == '019' || prefix == '014';
      case 'teletalk':
        return prefix == '015';
      default:
        return false;
    }
  }

  Future<void> _onSubmitRequest(
    SubmitRechargeRequest event,
    Emitter<RechargeState> emit,
  ) async {
    final phone = event.phone.trim();
    final operator = event.operator.trim();

    if (phone.isEmpty || operator.isEmpty) {
      emit(const RechargeValidationError('⚠️ সব ঘর পূরণ করুন!'));
      return;
    }

    if (event.amount < 20) {
      emit(const RechargeValidationError('সর্বনিম্ন ৳২০ রিচার্জ করুন'));
      return;
    }

    if (phone.length < 3 ||
        !_isOperatorPrefixValid(operator, phone.substring(0, 3))) {
      emit(const RechargeValidationError(
        '⚠️ ওপারেটরের সাথে মোবাইল নাম্বারের মিল নেই!',
      ));
      return;
    }

    emit(const RechargeSubmitting());
    _isSubmittingRequest = true;
    try {
      await repository.submitRechargeRequest(
        uid: event.uid,
        userName: event.userName,
        phone: phone,
        operator: operator,
        connectionType: event.connectionType,
        amount: event.amount,
      );
      await _refreshUser();
      _isSubmittingRequest = false;
      emit(const RechargeSubmitted(
        successMessage: 'রিচার্জ রিকোয়েস্ট সাবমিট হয়েছে! অনুমোদনের জন্য অপেক্ষা করুন',
      ));
    } catch (e) {
      _isSubmittingRequest = false;
      dev.log('❌ [RechargeBloc] Submit error: $e');
      emit(RechargeError(e.toString()));
    }
  }

  Future<void> _onTransferFromWallet(
    TransferFromWallet event,
    Emitter<RechargeState> emit,
  ) async {
    if (event.amount < 20) {
      emit(const RechargeError('সর্বনিম্ন পরিমাণ ৳২০'));
      return;
    }
    if (event.amount > event.currentMainBalance) {
      emit(const RechargeError('পর্যাপ্ত মেইন ব্যালেন্স নেই'));
      return;
    }
    emit(const RechargeSubmitting());
    try {
      await repository.transferFromMainWallet(
        uid: event.uid,
        amount: event.amount,
      );
      await _refreshUser();
      emit(const RechargeSubmitted(
        successMessage: 'মেইন ওয়ালেট থেকে রিচার্জ ব্যালেন্সে ট্রান্সফার সফল হয়েছে!',
      ));
    } catch (e) {
      dev.log('❌ [RechargeBloc] Transfer error: $e');
      emit(RechargeError(e.toString()));
    }
  }


}
