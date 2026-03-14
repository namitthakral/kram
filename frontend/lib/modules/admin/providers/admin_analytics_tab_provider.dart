import '../../../provider/segmented_control_provider.dart';

/// Tab options for Admin Analytics
enum AdminAnalyticsTab { performance, attendance, financial, staff, reviews }

/// Provider for managing the Analytics Tab state in Admin Dashboard
/// This allows any component to access and update the selected analytics tab
class AdminAnalyticsTabProvider
    extends SegmentedControlProvider<AdminAnalyticsTab> {
  AdminAnalyticsTabProvider()
    : super(
        initialValue: AdminAnalyticsTab.performance,
        segments: const {
          AdminAnalyticsTab.performance: 'Performance',
          AdminAnalyticsTab.attendance: 'Attendance',
          AdminAnalyticsTab.financial: 'Financial',
          AdminAnalyticsTab.staff: 'Staff',
          AdminAnalyticsTab.reviews: 'Performance Reviews',
        },
      );
}
