import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/support/data/repositories/support_repository.dart';
import 'package:global_earn/features/support/presentation/bloc/support_event.dart';
import 'package:global_earn/features/support/presentation/bloc/support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  final SupportRepository _repository;
  final Connectivity _connectivity;

  SupportBloc({
    required SupportRepository repository,
    Connectivity? connectivity,
  })  : _repository = repository,
        _connectivity = connectivity ?? Connectivity(),
        super(SupportInitial()) {
    on<FetchSupportAgents>(_onFetchSupportAgents);
  }

  Future<void> _onFetchSupportAgents(
    FetchSupportAgents event,
    Emitter<SupportState> emit,
  ) async {
    emit(SupportLoading());
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        emit(SupportNoInternet());
        return;
      }

      final settings = await _repository.getActiveSupportAgents();
      emit(SupportLoaded(data: settings));
    } catch (e) {
      emit(SupportError(message: 'Failed to load support agents: $e'));
    }
  }
}
