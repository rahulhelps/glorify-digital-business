import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'network_event.dart';
import 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final UserBloc _userBloc;
  StreamSubscription? _userSubscription;

  NetworkBloc({required UserBloc userBloc})
    : _userBloc = userBloc,
      super(const NetworkInitial()) {
    on<NetworkStarted>(_onStarted);
    on<NetworkRefreshRequested>(_onRefreshRequested);

    _userSubscription = _userBloc.stream.listen((userState) {
      if (userState is UserLoaded) {
        add(const NetworkStarted());
      }
    });
  }

  Future<void> _onStarted(
    NetworkStarted event,
    Emitter<NetworkState> emit,
  ) async {
    final userState = _userBloc.state;
    if (userState is UserLoaded) {
      final user = userState.user;
      dev.log(
        '🔥 [Network] Loading team data for uid: ${user.uid}',
        name: 'Network',
      );

      emit(const NetworkLoading());

      try {
        final team = user.team;
        final total =
            team.level1 +
            team.level2 +
            team.level3 +
            team.level4 +
            team.level5 +
            team.level6 +
            team.level7 +
            team.level8 +
            team.level9 +
            team.level10;

        dev.log('✅ [Network] Total team: $total', name: 'Network');

        emit(NetworkReady(user: user, totalTeam: total));
      } catch (e) {
        emit(NetworkError(e.toString()));
      }
    } else {
      emit(const NetworkLoading());
    }
  }

  Future<void> _onRefreshRequested(
    NetworkRefreshRequested event,
    Emitter<NetworkState> emit,
  ) async {
    add(const NetworkStarted());
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
