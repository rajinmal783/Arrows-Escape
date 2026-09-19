import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/storage_provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/leaderboard_entry.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _periods = ['all_time', 'monthly', 'weekly', 'daily'];
  final List<String> _periodTitles = ['All Time', 'This Month', 'This Week', 'Today'];

  List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _periods.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchLeaderboard(_periods[_tabController.index]);
      }
    });
    _fetchLeaderboard(_periods[0]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchLeaderboard(String period) async {
    setState(() => _isLoading = true);
    final service = ref.read(supabaseServiceProvider);
    final list = await service.fetchLeaderboard(periodType: period);

    if (mounted) {
      setState(() {
        _entries = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentProfile = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LEADERBOARD'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          indicatorColor: AppColors.primaryBlue,
          indicatorWeight: 3,
          tabs: _periodTitles.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : _entries.isEmpty
              ? _buildEmptyState(currentProfile, isDark)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: _entries.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    final isMe = entry.username == currentProfile.username;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMe
                            ? AppColors.primaryBlue.withAlpha(38)
                            : (isDark ? AppColors.surfaceDark : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isMe
                              ? AppColors.primaryBlue
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Rank Medal / Number
                          SizedBox(
                            width: 32,
                            child: _buildRankBadge(entry.rank),
                          ),
                          const SizedBox(width: 12),

                          // Avatar
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primaryBlue.withAlpha(51),
                            child: Text(
                              entry.username.isNotEmpty ? entry.username[0].toUpperCase() : 'P',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Username
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.username,
                                  style: TextStyle(
                                    fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                                    color: isMe ? AppColors.primaryBlue : null,
                                  ),
                                ),
                                Text(
                                  'Level ${entry.playerLevel}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          // Score & Stars
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${entry.score} pts',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: AppColors.accentAmber),
                                  const SizedBox(width: 2),
                                  Text('${entry.stars}', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(dynamic profile, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.leaderboard_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Be the First on the Board!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete levels to register your high scores.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    if (rank == 1) return const Text('🥇', style: TextStyle(fontSize: 20));
    if (rank == 2) return const Text('🥈', style: TextStyle(fontSize: 20));
    if (rank == 3) return const Text('🥉', style: TextStyle(fontSize: 20));
    return Text(
      '$rank',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
    );
  }
}
