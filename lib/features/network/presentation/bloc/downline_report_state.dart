import 'package:equatable/equatable.dart';
import 'package:global_earn/features/network/data/models/downline_user_model.dart';

abstract class DownlineReportState extends Equatable {
  const DownlineReportState();

  @override
  List<Object?> get props => [];
}

class DownlineInitial extends DownlineReportState {
  const DownlineInitial();
}

class DownlineLoading extends DownlineReportState {
  const DownlineLoading();
}

class DownlineLoaded extends DownlineReportState {
  final List<DownlineUserModel> allUsers;
  final List<DownlineUserModel> filteredUsers;
  final int totalCount;
  final int premiumCount;
  final int normalCount;
  final String activeFilter;
  final String searchQuery;

  const DownlineLoaded({
    required this.allUsers,
    required this.filteredUsers,
    required this.totalCount,
    required this.premiumCount,
    required this.normalCount,
    this.activeFilter = 'all',
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
    allUsers,
    filteredUsers,
    totalCount,
    premiumCount,
    normalCount,
    activeFilter,
    searchQuery,
  ];

  DownlineLoaded copyWith({
    List<DownlineUserModel>? filteredUsers,
    String? activeFilter,
    String? searchQuery,
  }) {
    return DownlineLoaded(
      allUsers: allUsers,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      totalCount: totalCount,
      premiumCount: premiumCount,
      normalCount: normalCount,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DownlineError extends DownlineReportState {
  final String message;

  const DownlineError(this.message);

  @override
  List<Object?> get props => [message];
}
