import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/home/domain/repositories/bonus_repository.dart';
import 'bonus_event.dart';
import 'bonus_state.dart';

class BonusBloc extends Bloc<BonusEvent, BonusState> {
  final BonusRepository _repository;

  BonusBloc({required BonusRepository repository})
    : _repository = repository,
      super(BonusInitial()) {
    on<LoadBonusStatus>(_onLoad);
    on<ClaimBonus>(_onClaim);
  }

  Future<void> _onLoad(LoadBonusStatus event, Emitter<BonusState> emit) async {
    emit(BonusLoading());
    try {
      final data = await _repository.loadBonusStatus(event.bonusType);
      emit(BonusLoaded(data));
    } catch (e) {
      debugPrint('❌ [Bonus] Error: $e');
      emit(BonusError(_friendlyError(e)));
    }
  }

  Future<void> _onClaim(ClaimBonus event, Emitter<BonusState> emit) async {
    final currentData = state is BonusLoaded
        ? (state as BonusLoaded).data
        : <String, dynamic>{};
    emit(BonusLoading());
    try {
      await _repository.claimBonus(
        bonusType: event.bonusType,
        amount: event.amount,
        bonusName: event.bonusName,
        extraClaimData: event.extraClaimData,
      );
      emit(BonusClaimed(event.bonusType));
      // Reload fresh data after claim
      final data = await _repository.loadBonusStatus(event.bonusType);
      emit(BonusLoaded(data));
    } catch (e) {
      debugPrint('❌ [Bonus] Error: $e');
      emit(BonusError(_friendlyError(e)));
      // Restore previous data so UI doesn't go blank
      if (currentData.isNotEmpty) {
        emit(BonusLoaded(currentData));
      }
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection')) {
      return 'ইন্টারনেট সংযোগ নেই';
    }
    if (msg.contains('already') ||
        msg.contains('claimed') ||
        msg.contains('ইতোমধ্যে')) {
      return 'এই বোনাস ইতোমধ্যে নেওয়া হয়েছে';
    }
    if (msg.contains('not eligible') ||
        msg.contains('requirements') ||
        msg.contains('verified')) {
      return 'এখনো যোগ্যতা অর্জন হয়নি';
    }
    return 'বোনাস দাবি করতে সমস্যা হয়েছে, আবার চেষ্টা করুন';
  }
}
