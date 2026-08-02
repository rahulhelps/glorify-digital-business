import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/constants/app_sizes.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/network/data/models/downline_user_model.dart';
import 'package:global_earn/features/network/domain/repositories/network_repository.dart';
import 'package:global_earn/features/network/presentation/widgets/network_stats_row.dart';
import 'package:global_earn/service_locator.dart';
import 'package:intl/intl.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  // HIDDEN TOP CARDS (Commented out as per rules)
  // const NetworkBanner(),
  // _buildUplineButton(context, user.referredBy),
  // _buildDownlineButton(context, user.referCode),

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is UserLoaded) {
          final user = state.user;
          return _NetworkContent(user: user);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _NetworkContent extends StatefulWidget {
  final UserModel user;
  const _NetworkContent({required this.user});

  @override
  State<_NetworkContent> createState() => _NetworkContentState();
}

class _NetworkContentState extends State<_NetworkContent> {
  final ScrollController _scrollController = ScrollController();
  final NetworkRepository _repo = sl<NetworkRepository>();

  List<DownlineUserModel> _users = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;

  String _searchQuery = '';
  String _activeFilter = 'all'; // all, verified, unverified

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final result = await _repo.getPaginatedDownlines(
        widget.user.referCode,
        startAfter: _lastDoc,
        limit: 20,
      );

      final newUsers = result.$1;
      final newLastDoc = result.$2;

      setState(() {
        if (newUsers.length < 20) {
          _hasMore = false;
        }
        _users.addAll(newUsers);
        _lastDoc = newLastDoc;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<DownlineUserModel> get _filteredUsers {
    return _users.where((u) {
      // Filter
      if (_activeFilter == 'verified' && !u.hasAnyActivePlan) return false;
      if (_activeFilter == 'unverified' && u.hasAnyActivePlan) return false;

      // Search
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!u.name.toLowerCase().contains(q) &&
            !u.referCode.toLowerCase().contains(q) &&
            !u.phone.toLowerCase().contains(q) &&
            !u.email.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  int get _totalTeamCount {
    final t = widget.user.team;
    return (t.level1 + t.level2 + t.level3 + t.level4 + t.level5 + 
            t.level6 + t.level7 + t.level8 + t.level9 + t.level10).toInt();
  }

  int get _verifiedCount {
    final t = widget.user.team;
    return (t.level1Business + t.level2Business + t.level3Business + 
            t.level4Business + t.level5Business + t.level6Business + 
            t.level7Business + t.level8Business + t.level9Business + 
            t.level10Business).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 1. Generations List (Top)
          SliverToBoxAdapter(
            child: TopGenerationsList(user: widget.user),
          ),
          
          // 2. Network Stats (Middle)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: NetworkStatsRow(
                total: _totalTeamCount,
                verified: _verifiedCount,
                unverified: _totalTeamCount - _verifiedCount,
                isLoading: false,
              ),
            ),
          ),

          // 3. Downline Search & Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DownlineSearchSection(
                onSearch: (q) => setState(() => _searchQuery = q),
                onFilterChanged: (f) => setState(() => _activeFilter = f),
                activeFilter: _activeFilter,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // 4. Paginated List of Users
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == _filteredUsers.length) {
                    return _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox(height: 40);
                  }
                  return _DownlineUserCard(user: _filteredUsers[index]);
                },
                childCount: _filteredUsers.length + (_hasMore ? 1 : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. TopGenerationsList (Levels 1-3 visible, 4-10 collapsed)
// ─────────────────────────────────────────────────────────────────────────────
class TopGenerationsList extends StatefulWidget {
  final UserModel user;
  const TopGenerationsList({super.key, required this.user});

  @override
  State<TopGenerationsList> createState() => _TopGenerationsListState();
}

class _TopGenerationsListState extends State<TopGenerationsList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.user.team;
    final levels = [
      {'level': 1, 'total': t.level1, 'verified': t.level1Business},
      {'level': 2, 'total': t.level2, 'verified': t.level2Business},
      {'level': 3, 'total': t.level3, 'verified': t.level3Business},
      {'level': 4, 'total': t.level4, 'verified': t.level4Business},
      {'level': 5, 'total': t.level5, 'verified': t.level5Business},
      {'level': 6, 'total': t.level6, 'verified': t.level6Business},
      {'level': 7, 'total': t.level7, 'verified': t.level7Business},
      {'level': 8, 'total': t.level8, 'verified': t.level8Business},
      {'level': 9, 'total': t.level9, 'verified': t.level9Business},
      {'level': 10, 'total': t.level10, 'verified': t.level10Business},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'টিম জেনারেশনস',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...levels.take(3).map((l) => _buildLevelCard(l)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              children: _expanded 
                  ? levels.skip(3).map((l) => _buildLevelCard(l)).toList()
                  : [],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _expanded ? 'View Less' : 'See More (Gen 4-10)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Modern rounded-square badge instead of heavy circle
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Gen\n${data['level']}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 12,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data['total']?.toInt() ?? 0}',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Total Members',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. DownlineSearchSection (Search Bar & Choice Chips)
// ─────────────────────────────────────────────────────────────────────────────
class DownlineSearchSection extends StatelessWidget {
  final Function(String) onSearch;
  final Function(String) onFilterChanged;
  final String activeFilter;

  const DownlineSearchSection({
    super.key,
    required this.onSearch,
    required this.onFilterChanged,
    required this.activeFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        TextField(
          onChanged: onSearch,
          decoration: InputDecoration(
            hintText: 'Search by Code, Phone, or Email...',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.primary, width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Filter Chips
        Row(
          children: [
            _buildChip(context, 'All', 'all'),
            const SizedBox(width: 8),
            _buildChip(context, 'Verified', 'verified'),
            const SizedBox(width: 8),
            _buildChip(context, 'Unverified', 'unverified'),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String label, String value) {
    final isSelected = activeFilter == value;
    final primary = AppColors.primary;
    return GestureDetector(
      onTap: () => onFilterChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. User Card & Lazy Loading Dialog
// ─────────────────────────────────────────────────────────────────────────────
class _DownlineUserCard extends StatelessWidget {
  final DownlineUserModel user;
  const _DownlineUserCard({required this.user});

  void _showUserDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _UserDetailsDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isVerified = user.hasAnyActivePlan;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showUserDetailsDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isNotEmpty ? user.name : 'Unknown User',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ref: ${user.referCode}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isVerified 
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isVerified ? 'Verified' : 'Unverified',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isVerified ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dialog that Lazy Loads Upline Info
class _UserDetailsDialog extends StatefulWidget {
  final DownlineUserModel user;
  const _UserDetailsDialog({required this.user});

  @override
  State<_UserDetailsDialog> createState() => _UserDetailsDialogState();
}

class _UserDetailsDialogState extends State<_UserDetailsDialog> {
  UserModel? _upline;
  bool _isLoadingUpline = true;

  @override
  void initState() {
    super.initState();
    _fetchUpline();
  }

  Future<void> _fetchUpline() async {
    try {
      final repo = sl<NetworkRepository>();
      final chain = await repo.getUplineChain(widget.user.referredBy);
      if (chain.isNotEmpty && mounted) {
        setState(() {
          _upline = chain.first;
          _isLoadingUpline = false;
        });
      } else {
        setState(() => _isLoadingUpline = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingUpline = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User Details',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildDetailRow('Name', widget.user.name),
            _buildDetailRow('Phone', widget.user.phone),
            _buildDetailRow('Email', widget.user.email),
            _buildDetailRow('Joined', DateFormat('MMM dd, yyyy').format(widget.user.joinedAt)),
            
            const Divider(height: 32),
            
            Text(
              'Direct Referrer (1 Upline)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 12),
            
            if (_isLoadingUpline)
              const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
            else if (_upline != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_upline!.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                          Text('Ref: ${_upline!.referCode}', style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Text('No upline found', style: TextStyle(color: Colors.grey.shade800, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.grey.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
