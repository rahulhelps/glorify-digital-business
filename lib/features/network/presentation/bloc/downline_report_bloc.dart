import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/network/data/models/downline_user_model.dart';
import 'package:global_earn/features/network/domain/repositories/network_repository.dart';
import 'downline_report_event.dart';
import 'downline_report_state.dart';

class DownlineReportBloc
    extends Bloc<DownlineReportEvent, DownlineReportState> {
  final NetworkRepository _networkRepository;

  DownlineReportBloc({required NetworkRepository networkRepository})
    : _networkRepository = networkRepository,
      super(const DownlineInitial()) {
    on<LoadDownlines>(_onLoadDownlines);
    on<FilterDownlines>(_onFilterDownlines);
    on<SearchDownlines>(_onSearchDownlines);
  }

  Future<void> _onLoadDownlines(
    LoadDownlines event,
    Emitter<DownlineReportState> emit,
  ) async {
    emit(const DownlineLoading());
    try {
      final users = await _networkRepository.getAllDownlines(event.referCode);

      final premiumCount = users
          .where((u) => u.hasAnyActivePlan)
          .length;
      final normalCount = users
          .where((u) => !u.hasAnyActivePlan && !u.isPending)
          .length;

      emit(
        DownlineLoaded(
          allUsers: users,
          filteredUsers: users,
          totalCount: users.length,
          premiumCount: premiumCount,
          normalCount: normalCount,
        ),
      );
    } catch (e) {
      final msg =
          e.toString().contains('network') ||
              e.toString().contains('SocketException')
          ? 'ইন্টারনেট সংযোগ নেই'
          : 'ডেটা লোড করতে সমস্যা হয়েছে';
      emit(DownlineError(msg));
    }
  }

  void _onFilterDownlines(
    FilterDownlines event,
    Emitter<DownlineReportState> emit,
  ) {
    final current = state;
    if (current is! DownlineLoaded) return;

    final filtered = _applyFilterAndSearch(
      current.allUsers,
      filter: event.filter,
      query: current.searchQuery,
    );

    emit(current.copyWith(filteredUsers: filtered, activeFilter: event.filter));
  }

  void _onSearchDownlines(
    SearchDownlines event,
    Emitter<DownlineReportState> emit,
  ) {
    final current = state;
    if (current is! DownlineLoaded) return;

    final filtered = _applyFilterAndSearch(
      current.allUsers,
      filter: current.activeFilter,
      query: event.query,
    );

    emit(current.copyWith(filteredUsers: filtered, searchQuery: event.query));
  }

  List<DownlineUserModel> _applyFilterAndSearch(
    List<DownlineUserModel> all, {
    required String filter,
    required String query,
  }) {
    List<DownlineUserModel> result = all;

    // Apply status filter
    if (filter == 'premium') {
      result = result.where((u) => u.isPremium).toList();
    } else if (filter == 'normal') {
      result = result.where((u) => u.isNormal).toList();
    }

    // Apply search query
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((u) {
        return u.name.toLowerCase().contains(q) ||
            u.referCode.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }
}
