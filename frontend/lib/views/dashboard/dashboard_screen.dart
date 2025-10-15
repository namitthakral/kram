import 'package:flutter/material.dart';

import '../../utils/enum.dart';
import '../../utils/localization/app_localizations.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../widgets/custom_widgets/responsive_layout.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!.translate;

    return CustomMainScreenWithAppbar(
      appBarType: AppBarType.profile,
      showBackButton: false,
      title: translate('dashboard_greeting', params: {'name': 'Deepak'}),
      child: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) => const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mobile Dashboard Layout'),
          // Add your mobile-specific widgets here
        ],
      ),
    );

  Widget _buildTabletLayout(BuildContext context) => SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tablet Dashboard Layout'),
          const SizedBox(height: 16),
          // Use ResponsiveGrid for better tablet layout
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.gridColumns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 4,
            itemBuilder: (context, index) => Card(
              child: Center(child: Text('Card $index')),
            ),
          ),
        ],
      ),
    );

  Widget _buildDesktopLayout(BuildContext context) => SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Desktop Dashboard Layout'),
          const SizedBox(height: 24),
          // Use grid with more columns for desktop
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.gridColumns,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => Card(
              child: Center(child: Text('Card $index')),
            ),
          ),
        ],
      ),
    );
}
