import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../providers/teacher_classes_provider.dart';

class MyClassesScreen extends StatefulWidget {
  const MyClassesScreen({super.key});

  @override
  State<MyClassesScreen> createState() => _MyClassesScreenState();
}

class _MyClassesScreenState extends State<MyClassesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final loginProvider = context.read<LoginProvider>();
    final userUuid = loginProvider.currentUser?.uuid;
    final teacherId = loginProvider.currentUser?.teacher?.id;
    if (userUuid != null) {
      await context.read<TeacherClassesProvider>().loadTeacherClasses(
        userUuid,
        teacherId: teacherId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');
    final userName = user?.name ?? 'Teacher';
    final designation = teacher?.designation ?? 'Faculty';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return CustomMainScreenWithAppbar(
      title: 'My Classes',
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
        onNotificationIconPressed: () {},
      ),
      child: Consumer<TeacherClassesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.classes.isEmpty) {
            return const Center(child: Text('No classes assigned'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.classes.length,
            itemBuilder: (context, index) {
              final classData = provider.classes[index];
              final className = classData.displayName;
              final subject = classData.subjectName;
              final studentCount = '0'; // Student count not in ClassSection model
              final sectionId = classData.id;

              return _buildClassCard(
                context,
                className,
                subject,
                '$studentCount Students',
                sectionId,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context,
    String className,
    String subject,
    String studentCount,
    int sectionId,
  ) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap:
          () => context.pushNamed(
            'class_students',
            pathParameters: {
              'className': className,
              'sectionId': sectionId.toString(),
            },
          ),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: CustomAppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  className.split(' ').last,
                  style: const TextStyle(
                    color: CustomAppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    className,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                studentCount,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
