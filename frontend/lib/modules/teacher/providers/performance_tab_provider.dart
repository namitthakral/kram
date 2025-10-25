import '../../../provider/segmented_control_provider.dart';
import '../screens/teacher_dashboard_screen.dart';

/// Provider for managing the Performance Tab state in Teacher Dashboard
/// This allows any component to access and update the selected performance tab
class PerformanceTabProvider extends SegmentedControlProvider<PerformanceTab> {
  PerformanceTabProvider()
      : super(
          initialValue: PerformanceTab.attendance,
          segments: const {
            PerformanceTab.attendance: 'Attendance Trends',
            PerformanceTab.subject: 'Subject Performance',
            PerformanceTab.grade: 'Grade Distribution',
          },
        );
}
