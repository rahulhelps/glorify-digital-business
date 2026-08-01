import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/core/network/network_info.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_event.dart';
import 'package:global_earn/features/wallet/domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _walletRepository;
  final UserBloc _userBloc;
  final NetworkInfo _networkInfo;
  final FirebaseAuth _auth;

  WalletBloc({
    required WalletRepository walletRepository,
    required UserBloc userBloc,
    required NetworkInfo networkInfo,
    required FirebaseAuth auth,
  }) : _walletRepository = walletRepository,
       _userBloc = userBloc,
       _networkInfo = networkInfo,
       _auth = auth,
       super(const WalletInitial()) {
    on<WalletStarted>(_onStarted);
    on<WalletBalanceUpdated>(_onBalanceUpdated);
  }

  Future<void> _onStarted(
    WalletStarted event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    if (!await _networkInfo.isConnected) {
      emit(const WalletError("ইন্টারনেট সংযোগ নেই"));
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(const WalletError("ইউজার পাওয়া যায়নি"));
      return;
    }

    debugPrint('🔥 [Wallet] Starting balance stream...');

    await emit.forEach<UserModel>(
      _walletRepository.watchUserBalance(uid),
      onData: (user) {
        debugPrint('✅ [Wallet] Balance updated: ${user.balance.earning}');
        add(WalletBalanceUpdated(user));
        return WalletLoaded(user);
      },
      onError: (e, stackTrace) {
        debugPrint('❌ [Wallet] Error: $e');
        if (e is FirebaseException && e.code == 'permission-denied') {
          return const WalletError("ডেটা লোড করতে সমস্যা হয়েছে");
        }
        return WalletError("ডেটা লোড করতে সমস্যা হয়েছে: $e");
      },
    );
  }

  void _onBalanceUpdated(
    WalletBalanceUpdated event,
    Emitter<WalletState> emit,
  ) {
    _userBloc.add(UserLoadedEvent(event.user));
    // emit(WalletLoaded(event.user)); // emit.forEach already emits WalletLoaded
  }
}
