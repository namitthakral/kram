import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../../../utils/extensions.dart';
import '../../models/payment.dart';
import '../../providers/fees_provider.dart';
import '../../widgets/fee_stats_card.dart';

class FeeDashboardScreen extends StatefulWidget {
  const FeeDashboardScreen({super.key});

  @override
  State<FeeDashboardScreen> createState() => _FeeDashboardScreenState();
}

class _FeeDashboardScreenState extends State<FeeDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final institutionId =
        context.read<LoginProvider>().currentUser?.institutionId;
    if (institutionId != null) {
      context.read<FeesProvider>().loadFeeDashboardData(institutionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final institutionId =
        context.watch<LoginProvider>().currentUser?.institutionId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.translate('fees_management')),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppStyles.headlineSmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.blue500,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: context.translate('recent_payments')),
            Tab(text: context.translate('fee_structure')),
            Tab(text: context.translate('analytics')),
            Tab(text: context.translate('pending_fees')),
          ],
        ),
      ),
      body:
          institutionId == null
              ? Center(child: Text(context.translate('institution_not_found')))
              : Consumer<FeesProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading &&
                      provider.collectionSummary == null &&
                      provider.overdueSummary == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCards(provider),
                          const SizedBox(height: 24),
                          _buildQuickActions(context),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 400,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _RecentPaymentsTab(
                                  institutionId: institutionId,
                                  onRefresh: _loadData,
                                ),
                                _FeeStructureTab(),
                                _AnalyticsTab(),
                                _PendingFeesTab(institutionId: institutionId),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildSummaryCards(FeesProvider provider) {
    final summary = provider.collectionSummary;
    final overdue = provider.overdueSummary;
    final totalCollected = summary?.totalCollected ?? 0;
    final pending = summary?.totalPending ?? 0;
    final totalOverdue = overdue?.totalOverdue ?? 0;
    final paidStudents = provider.paidStudentsCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.translate('overview'), style: AppStyles.headlineSmall),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FeeStatsCard(
                title: context.translate('total_collected'),
                amount: totalCollected,
                color: Colors.green,
                icon: Icons.check_circle,
              ),
              const SizedBox(width: 16),
              FeeStatsCard(
                title: context.translate('pending'),
                amount: pending,
                color: Colors.orange,
                icon: Icons.pending,
              ),
              const SizedBox(width: 16),
              FeeStatsCard(
                title: context.translate('overdue'),
                amount: totalOverdue,
                color: Colors.red,
                icon: Icons.warning_amber_rounded,
              ),
              const SizedBox(width: 16),
              FeeStatsCard(
                title: context.translate('paid_students'),
                value: '$paidStudents',
                color: Colors.purple,
                icon: Icons.people,
                isCurrency: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(context.translate('quick_actions'), style: AppStyles.headlineSmall),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.5,
        children: [
          _buildActionCard(
            context,
            context.translate('fee_structures'),
            Icons.list_alt,
            Colors.blue.shade50,
            Colors.blue,
            () => context.push('/fees/structures'),
          ),
          _buildActionCard(
            context,
            context.translate('assign_fees'),
            Icons.person_add,
            Colors.green.shade50,
            Colors.green,
            () => context.push('/fees/assign'),
          ),
          _buildActionCard(
            context,
            context.translate('record_payment'),
            Icons.payment,
            Colors.purple.shade50,
            Colors.purple,
            () => context.push('/fees/payments/record'),
          ),
          _buildActionCard(
            context,
            context.translate('student_fees'),
            Icons.people_outline,
            Colors.orange.shade50,
            Colors.orange,
            () => context.push('/fees/student-fees'),
          ),
        ],
      ),
    ],
  );

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) => Card(
    elevation: 0,
    color: bgColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppStyles.titleMedium.copyWith(
              color: iconColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _RecentPaymentsTab extends StatelessWidget {
  const _RecentPaymentsTab({
    required this.institutionId,
    required this.onRefresh,
  });
  final int institutionId;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) => Consumer<FeesProvider>(
    builder: (context, provider, _) {
      final payments = provider.payments;
      final meta = provider.paymentsMeta;
      if (provider.isLoading && payments.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (payments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                context.translate('no_recent_payments'),
                style: AppStyles.bodyMedium.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meta != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${context.translate('total')}: ${meta['total'] ?? 0}',
                style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final p = payments[index];
                return _PaymentListTile(payment: p);
              },
            ),
          ),
        ],
      );
    },
  );
}

class _PaymentListTile extends StatelessWidget {
  const _PaymentListTile({required this.payment});
  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final user = payment.student?['user'];
    final studentName = user is Map ? (() {
      final firstName = user['firstName']?.toString() ?? '';
      final lastName = user['lastName']?.toString() ?? '';
      final fullName = '$firstName $lastName'.trim();
      return fullName.isEmpty ? '-' : fullName;
    })() : '-';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.payment, color: Colors.green.shade700),
        ),
        title: Text(studentName.toString(), style: AppStyles.titleSmall),
        subtitle: Text(
          DateFormat.yMMMd().format(payment.paymentDate),
          style: AppStyles.bodySmall,
        ),
        trailing: Text(
          '₹${payment.amount.toStringAsFixed(2)}',
          style: AppStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.success,
          ),
        ),
      ),
    );
  }
}

class _FeeStructureTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.list_alt, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          context.translate('manage_fee_structures'),
          style: AppStyles.bodyLarge.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.push('/fees/structures'),
          icon: const Icon(Icons.open_in_new),
          label: Text(context.translate('view_fee_structures')),
        ),
      ],
    ),
  );
}

class _AnalyticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<FeesProvider>(
    builder: (context, provider, _) {
      final summary = provider.paymentSummary;
      if (summary == null) {
        return Center(
          child: Text(
            context.translate('no_analytics_data'),
            style: AppStyles.bodyMedium.copyWith(color: Colors.grey[600]),
          ),
        );
      }
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryRow(
              context.translate('total_payments'),
              summary.totalPayments.toString(),
            ),
            _SummaryRow(
              context.translate('total_amount'),
              '₹${summary.totalAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 16),
            Text(
              context.translate('by_payment_method'),
              style: AppStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            ...summary.byMethod.entries.map((e) {
              final v = e.value;
              final count = v is Map ? (v['count'] ?? 0).toString() : '-';
              final amount = v is Map ? (v['amount'] ?? 0).toString() : '-';
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${e.key}: $count payments, ₹$amount',
                  style: AppStyles.bodySmall,
                ),
              );
            }),
            if (summary.monthlyTrends.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                context.translate('monthly_trends'),
                style: AppStyles.titleMedium,
              ),
              const SizedBox(height: 8),
              ...summary.monthlyTrends.take(6).map((m) {
                final month = m['month'] ?? '';
                final amount = m['amount'] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '$month: ₹${amount.toStringAsFixed(2)}',
                    style: AppStyles.bodySmall,
                  ),
                );
              }),
            ],
          ],
        ),
      );
    },
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppStyles.bodyMedium),
        Text(
          value,
          style: AppStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

class _PendingFeesTab extends StatelessWidget {
  const _PendingFeesTab({required this.institutionId});
  final int institutionId;

  @override
  Widget build(BuildContext context) => Consumer<FeesProvider>(
    builder: (context, provider, _) {
      final overdue = provider.overdueSummary;
      final fees = overdue?.fees ?? [];
      if (fees.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Colors.green[400],
              ),
              const SizedBox(height: 8),
              Text(
                context.translate('no_pending_overdue_fees'),
                style: AppStyles.bodyMedium.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        itemCount: fees.length,
        itemBuilder: (context, index) {
          final f = fees[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                ),
              ),
              title: Text(f.studentName, style: AppStyles.titleSmall),
              subtitle: Text(
                '${f.feeName} • ${f.daysOverdue} days overdue',
                style: AppStyles.bodySmall,
              ),
              trailing: Text(
                '₹${f.totalOverdueAmount.toStringAsFixed(2)}',
                style: AppStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              onTap: () => context.push('/fees/student-fees'),
            ),
          );
        },
      );
    },
  );
}
