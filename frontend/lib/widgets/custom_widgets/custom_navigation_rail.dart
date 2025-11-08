import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
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
import '../../utils/user_utils.dart';

class CustomNavigationRail extends StatefulWidget {
  const CustomNavigationRail({super.key, this.onExtendedChanged});

  final ValueChanged<bool>? onExtendedChanged;

  @override
  State<CustomNavigationRail> createState() => CustomNavigationRailState();
}

class CustomNavigationRailState extends State<CustomNavigationRail> {
  bool _isExtended = false;

  /// Public method to control the extended state from outside
  void setExtended(bool value) {
    if (_isExtended != value) {
      setState(() {
        _isExtended = value;
      });
      widget.onExtendedChanged?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<BottomNavProvider>();
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Modern navigation rail with glassmorphism
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          width: _isExtended ? 280 : 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.scaffoldBackgroundColor,
                theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
              ],
            ),
            border: Border(
              right: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: CustomAppColors.primary.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(4, 0),
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                children: [
                  // User Header Section (collapsible)
                  _buildUserHeader(context, theme),

                  const Divider(height: 1),

                  // Navigation Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children:
                          navProvider.navigationItems.isEmpty
                              ? []
                              : navProvider.navigationItems.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final item = entry.value;
                                final isSelected =
                                    navProvider.currentIndex == index;

                                return _NavigationRailItem(
                                  item: item,
                                  isSelected: isSelected,
                                  isExtended: _isExtended,
                                  onTap: () {
                                    navProvider.setIndex(index);
                                    // Collapse drawer when an option is clicked
                                    if (_isExtended) {
                                      setExtended(false);
                                    }
                                  },
                                );
                              }).toList(),
                    ),
                  ),

                  // Logout button
                  const Divider(height: 1),
                  _buildLogoutButton(context, theme),

                  // Modern toggle button at bottom
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CustomAppColors.primary.withValues(alpha: 0.1),
                          CustomAppColors.primary.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: CustomAppColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setExtended(!_isExtended),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Icon(
                            _isExtended
                                ? Icons.arrow_back_ios_new_rounded
                                : Icons.arrow_forward_ios_rounded,
                            color: CustomAppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _capitalizeRole(String role) {
    if (role.isEmpty) return role;
    return role
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Widget _buildUserHeader(
    BuildContext context,
    ThemeData theme,
  ) => Consumer<LoginProvider>(
    builder: (context, loginProvider, child) {
      final user = loginProvider.currentUser;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        margin: EdgeInsets.all(_isExtended ? 12 : 12),
        padding: EdgeInsets.all(_isExtended ? 16 : 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CustomAppColors.primary.withValues(alpha: 0.15),
              CustomAppColors.primary.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(_isExtended ? 20 : 16),
          border: Border.all(
            color: CustomAppColors.primary.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: CustomAppColors.primary.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Modern User Avatar with Ring
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring animation
                Container(
                  width: _isExtended ? 72 : 52,
                  height: _isExtended ? 72 : 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        CustomAppColors.primary.withValues(alpha: 0.3),
                        CustomAppColors.primary.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Avatar
                Container(
                  width: _isExtended ? 64 : 44,
                  height: _isExtended ? 64 : 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [CustomAppColors.primary, AppTheme.blue600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CustomAppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      UserUtils.getInitials(user?.name ?? 'User'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: _isExtended ? 22 : 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_isExtended) ...[
              const SizedBox(height: 16),
              // EdVerse ID with modern styling
              if (user?.edverseId != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CustomAppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: CustomAppColors.primary.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'EdVerse ID',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: CustomAppColors.primary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user!.edverseId!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: CustomAppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              // User Name with modern styling
              Text(
                user?.name ?? 'Guest User',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // User Role with badge style
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: CustomAppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CustomAppColors.primary.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  _capitalizeRole(user?.role?.roleName ?? 'No role'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: CustomAppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      );
    },
  );

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) => Container(
    margin: EdgeInsets.symmetric(horizontal: _isExtended ? 12 : 8, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.danger.withValues(alpha: 0.12),
          AppTheme.danger.withValues(alpha: 0.08),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppTheme.danger.withValues(alpha: 0.25),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.danger.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: _isExtended ? 16 : 8,
            vertical: _isExtended ? 16 : 14,
          ),
          child: Row(
            mainAxisAlignment:
                _isExtended
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.danger.withValues(alpha: 0.15),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: AppTheme.danger,
                  size: 20,
                ),
              ),
              if (_isExtended) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    context.translate('logout'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.danger,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppTheme.danger,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.translate('logout_title'),
                    style: context.textTheme.titleLg.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              context.translate('logout_message'),
              style: context.textTheme.bodyBase,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  context.translate('cancel'),
                  style: context.textTheme.labelBase.copyWith(
                    color: AppTheme.slate500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();

                  final loginProvider = context.read<LoginProvider>();
                  final navProvider = context.read<BottomNavProvider>();

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
                  navProvider.reset(); // Reset navigation state

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  if (context.mounted) {
                    context.router.goToLogin();

                    showCustomSnackbar(
                      message: context.translate('logout_success'),
                      type: SnackbarType.success,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.translate('logout'),
                  style: context.textTheme.labelBase.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

class _NavigationRailItem extends StatefulWidget {
  const _NavigationRailItem({
    required this.item,
    required this.isSelected,
    required this.isExtended,
    required this.onTap,
  });

  final NavigationItemModel item;
  final bool isSelected;
  final bool isExtended;
  final VoidCallback onTap;

  @override
  State<_NavigationRailItem> createState() => _NavigationRailItemState();
}

class _NavigationRailItemState extends State<_NavigationRailItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: widget.isExtended ? 12 : 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          gradient:
              widget.isSelected
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CustomAppColors.primary.withValues(alpha: 0.15),
                      CustomAppColors.primary.withValues(alpha: 0.08),
                    ],
                  )
                  : _isHovered
                  ? LinearGradient(
                    colors: [
                      CustomAppColors.primary.withValues(alpha: 0.06),
                      CustomAppColors.primary.withValues(alpha: 0.03),
                    ],
                  )
                  : null,
          borderRadius: BorderRadius.circular(16),
          border:
              widget.isSelected
                  ? Border.all(
                    color: CustomAppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  )
                  : _isHovered
                  ? Border.all(
                    color: CustomAppColors.primary.withValues(alpha: 0.15),
                    width: 1,
                  )
                  : null,
          boxShadow:
              widget.isSelected
                  ? [
                    BoxShadow(
                      color: CustomAppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: Tooltip(
            message:
                widget.isExtended
                    ? ''
                    : context.translate(widget.item.labelKey),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isExtended ? 16 : 12,
                  vertical: widget.isExtended ? 16 : 14,
                ),
                child: Row(
                  mainAxisAlignment:
                      widget.isExtended
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                  children: [
                    // Icon with subtle background
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            widget.isSelected
                                ? CustomAppColors.primary.withValues(
                                  alpha: 0.15,
                                )
                                : Colors.transparent,
                      ),
                      child: BaseImage(
                        asset: LocalAsset(
                          url:
                              widget.isSelected
                                  ? widget.item.iconFilledUrl
                                  : widget.item.iconUrl,
                        ),
                        height: 22,
                        width: 22,
                        fit: BoxFit.contain,
                        color:
                            widget.isSelected
                                ? CustomAppColors.primary
                                : theme.iconTheme.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    if (widget.isExtended) ...[
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          context.translate(widget.item.labelKey),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                widget.isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                            color:
                                widget.isSelected
                                    ? CustomAppColors.primary
                                    : theme.textTheme.bodyLarge?.color,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Selection indicator
                      if (widget.isSelected)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CustomAppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: CustomAppColors.primary.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
