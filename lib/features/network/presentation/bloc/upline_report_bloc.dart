import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/network/domain/repositories/network_repository.dart';
import 'upline_report_event.dart';
import 'upline_report_state.dart';

class UplineReportBloc extends Bloc<UplineReportEvent, UplineReportState> {
  final NetworkRepository _networkRepository;

  UplineReportBloc({required NetworkRepository networkRepository})
    : _networkRepository = networkRepository,
      super(UplineReportInitial()) {
    on<LoadUplineReport>(_onLoadUplineReport);
  }

  Future<void> _onLoadUplineReport(
    LoadUplineReport event,
    Emitter<UplineReportState> emit,
  ) async {
    emit(UplineReportLoading());
    try {
      final uplines = await _networkRepository.getUplineChain(event.referredBy);
      emit(UplineReportLoaded(uplines));
    } catch (e) {
      emit(UplineReportError(e.toString()));
    }
  }
}
