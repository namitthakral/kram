import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../../widgets/custom_widgets/unified_loader.dart';
import '../providers/teacher_classes_provider.dart';

class TimetablesListScreen extends StatefulWidget {
  const TimetablesListScreen({super.key});

  @override
  State<TimetablesListScreen> createState() => _TimetablesListScreenState();
}

class _TimetablesListScreenState extends State<TimetablesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginProvider = context.read<LoginProvider>();
      final userUuid = loginProvider.currentUser?.uuid;
      final teacherId = loginProvider.currentUser?.teacher?.id;
      if (userUuid != null) {
        context.read<TeacherClassesProvider>().loadTeacherClasses(
          userUuid,
          teacherId: teacherId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherClassesProvider>();
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');
    final userName = user?.name ?? 'Teacher';
    final designation = teacher?.designation ?? 'Faculty';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return CustomMainScreenWithAppbar(
      title: 'Timetables',
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
        onNotificationIconPressed: () {},
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('create_timetable'),
        backgroundColor: CustomAppColors.blue500,
        icon: const Icon(Icons.add),
        label: const Text('New Timetable'),
      ),
      child: Stack(
        children: [
          if (provider.error != null) Center(child: Text('Error: ${provider.error}')) else provider.classes.isEmpty
              ? const Center(child: Text('No classes found'))
              : ListView.builder(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 80, // Space for FAB
                ),
                itemCount: provider.classes.length,
                itemBuilder: (context, index) {
                  final cls = provider.classes[index];
                  final displayName = cls.displayName;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: CustomAppColors.blue500.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: CustomAppColors.blue500,
                        ),
                      ),
                      title: Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text('Manage Timetable'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        context.pushNamed('timetable_view');
                      },
                    ),
                  );
                },
              ),
          if (provider.isLoading) const UnifiedLoader(),
        ],
      ),
    );
  }
}
