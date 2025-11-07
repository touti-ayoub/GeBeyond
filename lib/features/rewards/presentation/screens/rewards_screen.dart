import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gobeyond/core/services/rewards_service.dart';
import 'package:gobeyond/features/rewards/domain/entities/reward.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  final RewardsService _rewardsService = RewardsService();
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _rewardsService.initialize();
    await _rewardsService.loadRewards();
    setState(() {
      _isLoading = false;
    });
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards & Loyalty'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AnimatedBuilder(
              animation: _rewardsService,
              builder: (context, _) {
                return CustomScrollView(
                  slivers: [
                    // Member Level Card
                    SliverToBoxAdapter(
                      child: _buildMemberLevelCard(),
                    ),

                    // Points Summary Card
                    SliverToBoxAdapter(
                      child: _buildPointsSummaryCard(),
                    ),

                    // Tabs Header
                    SliverToBoxAdapter(
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Active'),
                            Tab(text: 'Redeemed'),
                            Tab(text: 'Expired'),
                          ],
                        ),
                      ),
                    ),

                    // Tab Content
                    SliverFillRemaining(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildRewardsList(_rewardsService.activeRewards),
                          _buildRewardsList(_rewardsService.redeemedRewards),
                          _buildRewardsList(_rewardsService.expiredRewards),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildMemberLevelCard() {
    final memberLevel = _rewardsService.getMemberLevel();
    final pointsForNext = _rewardsService.getPointsForNextLevel();
    final progress = _rewardsService.getProgressToNextLevel();

    Color levelColor;
    IconData levelIcon;
    switch (memberLevel) {
      case 'Platinum':
        levelColor = const Color(0xFF9333EA);
        levelIcon = Icons.workspace_premium;
        break;
      case 'Gold':
        levelColor = const Color(0xFFEAB308);
        levelIcon = Icons.stars;
        break;
      case 'Silver':
        levelColor = const Color(0xFF6B7280);
        levelIcon = Icons.star_half;
        break;
      default:
        levelColor = const Color(0xFFCD7F32);
        levelIcon = Icons.star_outline;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [levelColor, levelColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: levelColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(levelIcon, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Membership',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        memberLevel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (pointsForNext > 0) ...[
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$pointsForNext points to next level',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPointsSummaryCard() {
    final totalPoints = _rewardsService.totalPoints;
    final activeCount = _rewardsService.activeRewards.length;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      size: 32, color: Colors.green),
                  const SizedBox(height: 8),
                  Text(
                    totalPoints.toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total Points',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: Colors.grey[300],
            ),
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.card_giftcard, size: 32, color: Colors.orange),
                  const SizedBox(height: 8),
                  Text(
                    activeCount.toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Active Rewards',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsList(List<Reward> rewards) {
    if (rewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No rewards here',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete bookings to earn more!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _rewardsService.loadRewards();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rewards.length,
        itemBuilder: (context, index) {
          final reward = rewards[index];
          return _buildRewardCard(reward);
        },
      ),
    );
  }

  Widget _buildRewardCard(Reward reward) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final bool isPromoCode = reward.promoCode != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPromoCode
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPromoCode ? Icons.local_offer : Icons.stars,
                    color: isPromoCode ? Colors.orange : Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isPromoCode) ...[
                        Text(
                          reward.promoCode!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${reward.discountPercent?.toStringAsFixed(0)}% Discount',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '${reward.points} Points',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (reward.isActive && !reward.isRedeemed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (reward.isRedeemed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'REDEEMED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (reward.isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'EXPIRED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (reward.description != null) ...[
              const SizedBox(height: 12),
              Text(
                reward.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Earned: ${dateFormat.format(reward.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (reward.expiryDate != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    reward.isExpired
                        ? 'Expired: ${dateFormat.format(reward.expiryDate!)}'
                        : 'Expires: ${dateFormat.format(reward.expiryDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: reward.daysUntilExpiry != null &&
                              reward.daysUntilExpiry! <= 7
                          ? Colors.red
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            if (reward.isRedeemed && reward.redeemedAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Redeemed: ${dateFormat.format(reward.redeemedAt!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (reward.isActive && !reward.isRedeemed && isPromoCode) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _redeemReward(reward),
                  icon: const Icon(Icons.redeem, size: 18),
                  label: const Text('Redeem Now'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _redeemReward(Reward reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Reward'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reward.promoCode != null) ...[
              Text('Use promo code: ${reward.promoCode}'),
              const SizedBox(height: 8),
              Text(
                'Get ${reward.discountPercent?.toStringAsFixed(0)}% off on your next booking!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to redeem this reward? This action cannot be undone.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await _rewardsService.redeemReward(reward.id!);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reward redeemed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to redeem reward'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
}
