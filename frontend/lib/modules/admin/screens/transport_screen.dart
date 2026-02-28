import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/extensions.dart';
import '../../../../utils/responsive_utils.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_form_dialog.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../../widgets/custom_widgets/custom_text_field.dart';

/// Transport route model (local until backend API exists)
class TransportRouteItem {
  const TransportRouteItem({
    required this.id,
    required this.routeName,
    required this.busNumber,
    required this.driverName,
    this.studentCount = 0,
  });

  final String id;
  final String routeName;
  final String busNumber;
  final String driverName;
  final int studentCount;
}

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final List<TransportRouteItem> _routes = [
    const TransportRouteItem(
      id: '1',
      routeName: 'Route 1: City Center',
      busNumber: 'WB-01-1234',
      driverName: 'Mike Ross',
      studentCount: 45,
    ),
    const TransportRouteItem(
      id: '2',
      routeName: 'Route 2: North Zone',
      busNumber: 'WB-01-5678',
      driverName: 'Harvey Specter',
      studentCount: 40,
    ),
    const TransportRouteItem(
      id: '3',
      routeName: 'Route 3: South Zone',
      busNumber: 'WB-01-9012',
      driverName: 'Louis Litt',
      studentCount: 38,
    ),
    const TransportRouteItem(
      id: '4',
      routeName: 'Route 4: East Side',
      busNumber: 'WB-01-3456',
      driverName: 'Rachel Zane',
      studentCount: 42,
    ),
  ];

  void _showAddRouteDialog(BuildContext context) {
    final routeNameController = TextEditingController();
    final busNumberController = TextEditingController();
    final driverNameController = TextEditingController();

    CustomFormDialog.show<void>(
      context: context,
      title: 'Add Route',
      subtitle: 'Add a new transport route',
      headerIcon: Icons.directions_bus_rounded,
      confirmText: 'Add',
      cancelText: context.translate('cancel'),
      confirmColor: AppTheme.blue500,
      maxWidth: 500,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: 'Route name',
            hintText: 'e.g. Route 1: City Center',
            controller: routeNameController,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please enter route name' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Bus number',
            hintText: 'e.g. WB-01-1234',
            controller: busNumberController,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please enter bus number' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Driver name',
            hintText: 'Driver full name',
            controller: driverNameController,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please enter driver name' : null,
          ),
        ],
      ),
      onConfirm: () {
        final name = routeNameController.text.trim();
        final bus = busNumberController.text.trim();
        final driver = driverNameController.text.trim();
        if (name.isNotEmpty && bus.isNotEmpty && driver.isNotEmpty) {
          setState(() {
            _routes.insert(
              0,
              TransportRouteItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                routeName: name,
                busNumber: bus,
                driverName: driver,
                studentCount: 0,
              ),
            );
          });
          routeNameController.dispose();
          busNumberController.dispose();
          driverNameController.dispose();
          Navigator.of(context).pop();
        }
      },
      onCancel: () {
        routeNameController.dispose();
        busNumberController.dispose();
        driverNameController.dispose();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';

    return CustomMainScreenWithAppbar(
      title: context.translate('transport'),
      appBarConfig: AppBarConfig.admin(
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
        onNotificationIconPressed: () {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRouteDialog(context),
        backgroundColor: AppTheme.blue500,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _routes.length,
        itemBuilder: (context, index) {
          final r = _routes[index];
          return _buildRouteCard(context, r, isMobile);
        },
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context,
    TransportRouteItem r,
    bool isMobile,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      r.routeName,
                      style: const TextStyle(
                        fontWeight: AppTheme.fontWeightSemibold,
                        fontSize: AppTheme.fontSizeBase,
                        color: AppTheme.slate800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.blue500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${r.studentCount} Students',
                      style: const TextStyle(
                        color: AppTheme.blue500,
                        fontWeight: AppTheme.fontWeightSemibold,
                        fontSize: AppTheme.fontSizeXs,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.directions_bus_rounded,
                    size: 18,
                    color: AppTheme.slate500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    r.busNumber,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeSm,
                      color: AppTheme.slate600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: AppTheme.slate500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    r.driverName,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeSm,
                      color: AppTheme.slate600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('View Stops'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.location_on_outlined, size: 18),
                    label: const Text('Track'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.blue500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
