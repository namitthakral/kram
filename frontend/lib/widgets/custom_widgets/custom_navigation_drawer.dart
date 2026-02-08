import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/navigation_item_model.dart';
import '../../provider/bottom_nav_provider.dart';
import '../../provider/login_signup/login_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/extensions.dart';
import '../../utils/images/base_image.dart';
import '../../utils/images/image_asset.dart';
import '../../utils/router_service.dart';
import 'custom_dialog.dart';

class CustomNavigationDrawer extends StatelessWidget {
  const CustomNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          // User Header Section
          _buildUserHeader(context, theme),

          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: Consumer<BottomNavProvider>(
              builder: (context, navProvider, child) {
                final currentRoute = GoRouterState.of(context).uri.path;

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children:
                      navProvider.navigationItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        if (navProvider.isItemHidden(index)) {
                          return const SizedBox.shrink();
                        }

                        final selectedIndex = navProvider.getCurrentIndex(
                          currentRoute,
                        );
                        final isSelected = selectedIndex == index;

                        return _buildNavigationItem(
                          context,
                          theme,
                          item: item,
                          isSelected: isSelected,
                          onTap:
                              () => navProvider.navigateToIndex(context, index),
                        );
                      }).toList(),
                );
              },
            ),
          ),

          // Footer Section (optional - settings, logout, etc.)
          _buildFooter(context, theme),
        ],
      ),
    );
  }

  Widget _buildUserHeader(
    BuildContext context,
    ThemeData theme,
  ) => Consumer<LoginProvider>(
    builder: (context, loginProvider, child) {
      final user = loginProvider.currentUser;

      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // User Avatar with Initials
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.blue500, AppTheme.blue600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: CustomAppColors.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: CustomAppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getInitials(user?.name ?? 'User'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // User Name
            Text(
              user?.name ?? 'Guest User',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // User Role or Email
            Text(
              user?.role?.roleName.capitalize ??
                  user?.email ??
                  'No role assigned',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // EdVerse ID Badge (if available)
            if (user?.edverseId != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: CustomAppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      size: 14,
                      color: CustomAppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user!.edverseId!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: CustomAppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    },
  );

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  Widget _buildNavigationItem(
    BuildContext context,
    ThemeData theme, {
    required NavigationItemModel item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const selectedColor = CustomAppColors.primary;
    final backgroundColor =
        isSelected ? selectedColor.withValues(alpha: 0.1) : Colors.transparent;
    final textColor =
        isSelected ? selectedColor : theme.textTheme.bodyLarge?.color;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: BaseImage(
          asset: LocalAsset(
            url: isSelected ? item.iconFilledUrl : item.iconUrl,
          ),
          height: 24,
          width: 24,
          fit: BoxFit.contain,
          color: isSelected ? selectedColor : null,
        ),
        title: Text(
          context.translate(item.labelKey),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: theme.dividerColor)),
    ),
    child: Column(
      children: [
        // Logout Button
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: AppTheme.danger,
              size: 24,
            ),
            title: Text(
              context.translate('logout'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _showLogoutDialog(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await CustomDialog.showConfirmation(
      context: context,
      title: context.translate('logout_title'),
      message: context.translate('logout_message'),
      confirmText: context.translate('logout'),
      cancelText: context.translate('cancel'),
      confirmColor: AppTheme.danger,
      icon: Icons.logout_rounded,
      iconColor: AppTheme.danger,
    );

    if (result == true && context.mounted) {
      final loginProvider = context.read<LoginProvider>();

      unawaited(
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (BuildContext loadingContext) =>
                  const Center(child: CircularProgressIndicator()),
        ),
      );

      await loginProvider.logout();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Use addPostFrameCallback to ensure dialog is fully dismissed before navigating
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.router.goToLogin();

            showCustomSnackbar(
              message: context.translate('logout_success'),
              type: SnackbarType.success,
            );
          }
        });
      }
    }
  }
}
