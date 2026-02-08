import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../widgets/custom_widgets/custom_dialog.dart';
import '../models/attendance_models.dart';
import '../providers/attendance_provider.dart';

class AttendanceHistoryTab extends StatefulWidget {
  const AttendanceHistoryTab({super.key});

  @override
  State<AttendanceHistoryTab> createState() => _AttendanceHistoryTabState();
}

class _AttendanceHistoryTabState extends State<AttendanceHistoryTab> {


  @override
  void initState() {
    super.initState();
    // Load initial data when tab opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  Future<void> _fetchHistory() async {
    final loginProvider = context.read<LoginProvider>();
    final userUuid = loginProvider.currentUser?.uuid;
    if (userUuid != null) {
      context.read<AttendanceProvider>().fetchAttendanceHistory(userUuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();

    return Column(
      children: [
        // Filters Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildFilterChip(
                      context,
                      label:
                          provider.historySelectedClass?.name ?? 'All Classes',
                      icon: Icons.class_,
                      onTap: () => _showClassFilter(context, provider),
                      isSelected: provider.historySelectedClass != null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip(
                      context,
                      label: provider.historyStatus ?? 'All Status',
                      icon: Icons.check_circle_outline,
                      onTap: () => _showStatusFilter(context, provider),
                      isSelected: provider.historyStatus != null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildFilterChip(
                context,
                label: _getDateRangeLabel(provider),
                icon: Icons.calendar_today,
                onTap: () => _showDateRangeFilter(context, provider),
                isSelected: provider.historyStartDate != null,
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // List Section
        Expanded(
          child:
              provider.historyLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.historyRecords.isEmpty
                  ? const Center(child: Text('No attendance records found'))
                  : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.historyRecords.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final record = provider.historyRecords[index];
                      return _buildHistoryCard(record);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isSelected = false,
  }) => InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? CustomAppColors.primary.withOpacity(0.1)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? CustomAppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  isSelected ? CustomAppColors.primary : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color:
                      isSelected
                          ? CustomAppColors.primary
                          : Colors.grey.shade800,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color:
                  isSelected ? CustomAppColors.primary : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );

  Widget _buildHistoryCard(Map<String, dynamic> record) {
    final student = record['student'] ?? {};
    final section = record['section'] ?? {};
    final date = DateTime.parse(record['date']);
    final status = record['status'] as String;

    Color statusColor;
    switch (status) {
      case 'PRESENT':
        statusColor = Colors.green;
        break;
      case 'ABSENT':
        statusColor = Colors.red;
        break;
      case 'LATE':
        statusColor = Colors.orange;
        break;
      case 'EXCUSED':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              student['name'] ?? 'Unknown Student',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${section['name'] ?? ''} • ${section['subject']?['name'] ?? ''}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateRangeLabel(AttendanceProvider provider) {
    if (provider.historyStartDate == null) return 'Select Date Range';
    final start = DateFormat('MMM dd').format(provider.historyStartDate!);
    if (provider.historyEndDate == null) return start;
    final end = DateFormat('MMM dd').format(provider.historyEndDate!);
    return '$start - $end';
  }

  Future<void> _showClassFilter(
    BuildContext context,
    AttendanceProvider provider,
  ) async {
    final selectedClass = await CustomDialog.showSelection<ClassInfo?>(
      context: context,
      title: 'Filter by Class',
      subtitle: 'Select a class to view history',
      headerIcon: Icons.filter_list,
      selectedValue: provider.historySelectedClass,
      items: [
        const SelectionItem<ClassInfo?>(
          value: null,
          label: 'All Classes',
          icon: Icons.clear_all,
        ),
        ...provider.availableClasses.map(
          (c) => SelectionItem<ClassInfo?>(
            value: c,
            label: c.name,
            subtitle: '${c.totalStudents} Students',
            icon: Icons.class_,
          ),
        ),
      ],
    );

    provider.setHistoryClass(selectedClass);
    if (context.mounted) _fetchHistory();
  }

  Future<void> _showStatusFilter(
    BuildContext context,
    AttendanceProvider provider,
  ) async {
    const statuses = ['PRESENT', 'ABSENT', 'LATE', 'EXCUSED'];

    final selectedStatus = await CustomDialog.showSelection<String?>(
      context: context,
      title: 'Filter by Status',
      subtitle: 'Select status to filter',
      headerIcon: Icons.filter_list,
      selectedValue: provider.historyStatus,
      items: [
        const SelectionItem<String?>(
          value: null,
          label: 'All Status',
          icon: Icons.clear_all,
        ),
        ...statuses.map(
          (s) => SelectionItem<String?>(
            value: s,
            label: s,
            icon: Icons.check_circle_outline,
          ),
        ),
      ],
    );

    provider.setHistoryStatus(selectedStatus);
    if (context.mounted) _fetchHistory();
  }

  Future<void> _showDateRangeFilter(
    BuildContext context,
    AttendanceProvider provider,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          provider.historyStartDate != null && provider.historyEndDate != null
              ? DateTimeRange(
                start: provider.historyStartDate!,
                end: provider.historyEndDate!,
              )
              : null,
    );

    if (picked != null) {
      provider.setHistoryDateRange(picked.start, picked.end);
      if (context.mounted) _fetchHistory();
    }
  }
}
