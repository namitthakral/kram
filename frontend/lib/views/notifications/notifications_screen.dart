
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/communication_model.dart';
import '../../provider/communications_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunicationsProvider>().fetchAllCommunications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('notifications')),
        centerTitle: false,
      ),
      body: Consumer<CommunicationsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.allCommunications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.allCommunications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_off_outlined, size: 64, color: CustomAppColors.slate400),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.slate600),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAllCommunications(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.allCommunications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final communication = provider.allCommunications[index];
                return _NotificationItem(communication: communication);
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Communication communication;

  const _NotificationItem({required this.communication});

  @override
  Widget build(BuildContext context) {
    // Determine icon based on type
    IconData iconData;
    Color iconColor;

    switch (communication.communicationType.toLowerCase()) {
      case 'emergency':
        iconData = Icons.warning_amber_rounded;
        iconColor = CustomAppColors.danger;
        break;
      case 'event':
        iconData = Icons.event;
        iconColor = CustomAppColors.info;
        break;
      case 'academic':
        iconData = Icons.school;
        iconColor = CustomAppColors.warning;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = CustomAppColors.primary;
    }

    if (communication.isEmergency) {
      iconColor = CustomAppColors.danger;
      iconData = Icons.campaign;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: communication.isRead ? AppTheme.slate200 : CustomAppColors.primary.withValues(alpha: 0.3),
          width: communication.isRead ? 1 : 1.5,
        ),
      ),
      color: communication.isRead ? Colors.white : CustomAppColors.primary.withValues(alpha: 0.02),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        title: Text(
          communication.title,
          style: TextStyle(
            fontWeight: communication.isRead ? FontWeight.normal : FontWeight.bold,
            color: AppTheme.slate800,
          ),
        ),
        subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              DateFormat('MMM d, y • h:mm a').format(communication.publishDate),
              style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
            ),
          ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        onExpansionChanged: (expanded) {
          if (expanded && !communication.isRead) {
            context.read<CommunicationsProvider>().markAsRead(communication.id);
          }
        },
        children: [
          const Divider(),
          Text(
            communication.content,
            style: const TextStyle(color: CustomAppColors.slate700, height: 1.5),
          ),
          if (communication.attachmentUrl != null) ...[
             const SizedBox(height: 12),
             OutlinedButton.icon(
               onPressed: () {
                 // Open attachment logic here
               },
               icon: const Icon(Icons.attachment, size: 18),
               label: const Text('View Attachment'),
             ),
          ],
        ],
      ),
    );
  }
}
