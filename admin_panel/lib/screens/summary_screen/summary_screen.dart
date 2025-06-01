import 'dart:async';
import 'package:flutter/material.dart';
import 'package:statistics_repository/statistics_repository.dart';
import 'package:winball_admin_panel/bloc/app_bloc/app_bloc.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:winball_admin_panel/widgets/widgets.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final ValueNotifier<bool> isRefreshingValueNotifier;
  late final ValueNotifier<StatisticsModel> statisticModelValueNotifier;
  late final SiteStatisticsRepositoryFunctions siteStatisticsRepositoryFunctions;
  late Timer? refreshTimer;
  DateTime? lastUpdateTime;

  Future<void> initializeDatas() async {
    isLoadingValueNotifier = ValueNotifier<bool>(true);
    isRefreshingValueNotifier = ValueNotifier<bool>(false);
    statisticModelValueNotifier = ValueNotifier<StatisticsModel>(StatisticsModel.empty);
    siteStatisticsRepositoryFunctions = const SiteStatisticsRepositoryFunctions();
    
    await _loadStatistics();
    _setupAutoRefresh();
  }

  void _setupAutoRefresh() {
    // Auto refresh every 5 minutes
    refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted && !isRefreshingValueNotifier.value) {
        _refreshStatistics();
      }
    });
  }

  Future<void> _loadStatistics() async {
    final AppBloc appBloc = context.readAppBloc;
    
    try {
      final StatisticsModel statistics = await siteStatisticsRepositoryFunctions.getSiteStatistics(
          token: appBloc.state.currentUser.token ?? '',
      );
      
      if (mounted) {
        changeStatisticsModelValueNotifier(statisticsModel: statistics);
      changeIsLoadingValueNotifier(isLoading: false);
        lastUpdateTime = DateTime.now();
      }
    } catch (e) {
      if (mounted) {
      changeIsLoadingValueNotifier(isLoading: false);
      appBloc.addError(e);
    }
  }
  }

  Future<void> _refreshStatistics() async {
    if (isLoadingValueNotifier.value || isRefreshingValueNotifier.value) return;
    
    changeIsRefreshingValueNotifier(isRefreshing: true);
    
    try {
      await _loadStatistics();
    } finally {
      if (mounted) {
        changeIsRefreshingValueNotifier(isRefreshing: false);
      }
    }
  }

  void changeStatisticsModelValueNotifier({required StatisticsModel statisticsModel}) {
    if (mounted) {
    statisticModelValueNotifier.value = statisticsModel;
    }
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    if (mounted) {
    isLoadingValueNotifier.value = isLoading ?? !isLoadingValueNotifier.value;
    }
  }

  void changeIsRefreshingValueNotifier({bool? isRefreshing}) {
    if (mounted) {
      isRefreshingValueNotifier.value = isRefreshing ?? !isRefreshingValueNotifier.value;
    }
  }

  void dispositionalDatas() {
    refreshTimer?.cancel();
    isLoadingValueNotifier.dispose();
    isRefreshingValueNotifier.dispose();
    statisticModelValueNotifier.dispose();
  }

  String _formatTonAmount(double amount) {
    final double formattedAmount = amount / AppConfigs.tonBaseFactory;
    if (formattedAmount >= 1000000) {
      return '${(formattedAmount / 1000000).toStringAsFixed(2)}M';
    } else if (formattedAmount >= 1000) {
      return '${(formattedAmount / 1000).toStringAsFixed(2)}K';
    }
    return formattedAmount.toStringAsFixed(2);
  }

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'TON',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
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

  @override
  void initState() {
    super.initState();
    initializeDatas();
  }

  @override
  void dispose() {
    dispositionalDatas();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = context.getSize;
    final bool isMobile = size.width.isMobile;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Statistics'),
        backgroundColor: AppConfigs.lightBlueButtonColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (lastUpdateTime != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  'Updated: ${TimeOfDay.fromDateTime(lastUpdateTime!).format(context)}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            ),
          ValueListenableBuilder<bool>(
            valueListenable: isRefreshingValueNotifier,
            builder: (context, isRefreshing, _) {
              return IconButton(
                icon: isRefreshing 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Refresh Statistics',
                onPressed: isRefreshing ? null : _refreshStatistics,
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoadingValueNotifier,
        builder: (context, isLoading, child) {
          return isLoading ? const LoadingWidget() : child!;
        },
        child: RefreshIndicator(
          onRefresh: _refreshStatistics,
        child: ValueListenableBuilder<StatisticsModel>(
          valueListenable: statisticModelValueNotifier,
          builder: (context, statistics, _) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Summary header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppConfigs.lightBlueButtonColor, AppConfigs.darkBlueColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.analytics_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Platform Statistics',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Real-time data overview',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Income Statistics
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.trending_up, color: Colors.green[600]),
                              const SizedBox(width: 8),
                              Text(
                                'Income Statistics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isMobile ? 1 : 3,
                              childAspectRatio: isMobile ? 2.5 : 1.2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            children: [
                              _buildStatisticCard(
                                title: 'Daily Income',
                                value: _formatTonAmount(statistics.incomeTonAmountPerDay),
                                icon: Icons.today,
                                color: Colors.green,
                              ),
                              _buildStatisticCard(
                                title: 'Monthly Income',
                                value: _formatTonAmount(statistics.incomeTonAmountPerMonth),
                                icon: Icons.calendar_month,
                                color: Colors.green[600]!,
                              ),
                              _buildStatisticCard(
                                title: 'Yearly Income',
                                value: _formatTonAmount(statistics.incomeTonAmountPerYear),
                                icon: Icons.calendar_today,
                                color: Colors.green[800]!,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Outgoing Statistics
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.trending_down, color: Colors.orange[600]),
                              const SizedBox(width: 8),
                              Text(
                                'Withdrawal Statistics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isMobile ? 1 : 3,
                              childAspectRatio: isMobile ? 2.5 : 1.2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
              ),
              children: [
                              _buildStatisticCard(
                                title: 'Daily Withdrawal',
                                value: _formatTonAmount(statistics.outgoingTonAmountPerDay),
                                icon: Icons.today,
                                color: Colors.orange,
                              ),
                              _buildStatisticCard(
                                title: 'Monthly Withdrawal',
                                value: _formatTonAmount(statistics.outgoingTonAmountPerMonth),
                                icon: Icons.calendar_month,
                                color: Colors.orange[600]!,
                              ),
                              _buildStatisticCard(
                                title: 'Yearly Withdrawal',
                                value: _formatTonAmount(statistics.outgoingTonAmountPerYear),
                                icon: Icons.calendar_today,
                                color: Colors.orange[800]!,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // User Statistics
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.people, color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              Text(
                                'User Statistics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isMobile ? 1 : 3,
                              childAspectRatio: isMobile ? 3 : 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            children: [
                              _buildUserStatCard(
                                title: 'Total Users',
                                value: '${statistics.usersCount}',
                                icon: Icons.person,
                                color: Colors.blue,
                              ),
                              _buildUserStatCard(
                                title: 'Winners',
                                value: '${statistics.winnerCount}',
                                icon: Icons.emoji_events,
                                color: Colors.amber,
                              ),
                              _buildUserStatCard(
                                title: 'Players',
                                value: '${statistics.losersCount}',
                                icon: Icons.sports_esports,
                                color: Colors.purple,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
