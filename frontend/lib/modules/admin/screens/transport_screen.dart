import 'package:flutter/material.dart';
import '../../../../utils/custom_colors.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock admin data
    const userInitials = 'AD';
    const userName = 'Admin';
    const institutionName = 'Greenwood High';

    return CustomMainScreenWithAppbar(
      title: 'Transport',
      appBarConfig: AppBarConfig.admin(
        userInitials: userInitials,
        userName: userName,
        institutionName: institutionName,
        onNotificationIconPressed: () {},
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRouteCard(
            'Route 1: City Center',
            'Bus No: WB-01-1234',
            'Driver: Mike Ross',
            '45 Students',
          ),
          _buildRouteCard(
            'Route 2: North Zone',
            'Bus No: WB-01-5678',
            'Driver: Harvey Specter',
            '40 Students',
          ),
          _buildRouteCard(
            'Route 3: South Zone',
            'Bus No: WB-01-9012',
            'Driver: Louis Litt',
            '38 Students',
          ),
          _buildRouteCard(
            'Route 4: East Side',
            'Bus No: WB-01-3456',
            'Driver: Rachel Zane',
            '42 Students',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: CustomAppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRouteCard(
    String routeName,
    String busNo,
    String driver,
    String count,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  routeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.directions_bus, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(busNo, style: TextStyle(color: Colors.grey[800])),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(driver, style: TextStyle(color: Colors.grey[800])),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () {}, child: const Text('View Stops')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: CustomAppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Track'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
