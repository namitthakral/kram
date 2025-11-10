import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/extensions.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  bool _paymentNotifications = true;
  bool _scheduleNotifications = true;
  bool _cancellationNotifications = true;
  bool _generalNotifications = true;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          context,
          title: 'Push Notifications',
          children: [
            _buildSwitchTile(
              title: context.translate('payment'),
              subtitle: 'Receive notifications about payments',
              value: _paymentNotifications,
              onChanged: (value) {
                setState(() {
                  _paymentNotifications = value;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: context.translate('schedule'),
              subtitle: 'Receive notifications about schedule changes',
              value: _scheduleNotifications,
              onChanged: (value) {
                setState(() {
                  _scheduleNotifications = value;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: context.translate('cancellation'),
              subtitle: 'Receive notifications about cancellations',
              value: _cancellationNotifications,
              onChanged: (value) {
                setState(() {
                  _cancellationNotifications = value;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: context.translate('notification'),
              subtitle: 'Receive general notifications',
              value: _generalNotifications,
              onChanged: (value) {
                setState(() {
                  _generalNotifications = value;
                });
              },
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.slate100),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.slate800,
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    ),
  );

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.slate100,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.slate800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppTheme.blue500,
          activeThumbColor: Colors.white,
        ),
      ],
    ),
  );
}
