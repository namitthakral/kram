import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/custom_colors.dart';
import '../../utils/enum.dart';
import '../../utils/extensions.dart';
import '../../utils/responsive_utils.dart';
import 'unified_loader.dart';

/// Configuration class for app bar customization
class AppBarConfig {
  const AppBarConfig({
    this.type = AppBarType.none,
    this.showBackButton = true,
    this.showCircularBackButton = false,
    this.onBackButtonTapped,
    this.actions = const [],
    this.onNotificationIconPressed,
    this.profileIcon,
    this.subtitle,
    this.iconBackgroundColor,
    this.elevation = 5.0,
    this.userInitials,
    this.userName,
    this.userDetails,
    this.gpa,
    this.rank,
    this.totalRank,
  });

  /// Creates a student app bar configuration
  const AppBarConfig.student({
    required String this.userInitials,
    required String this.userName,
    required String grade,
    required String rollNumber,
    this.gpa,
    this.onNotificationIconPressed,
    this.elevation = 5.0,
  }) : type = AppBarType.profile,
       profileIcon = null,
       iconBackgroundColor = CustomAppColors.primary,
       showBackButton = false,
       showCircularBackButton = false,
       onBackButtonTapped = null,
       actions = const [],
       userDetails =
           gpa != null
               ? '$grade • Roll No: $rollNumber • GPA: $gpa'
               : '$grade • Roll No: $rollNumber',
       subtitle = null,
       rank = null,
       totalRank = null;

  /// Creates a teacher app bar configuration
  const AppBarConfig.teacher({
    required String this.userInitials,
    required String this.userName,
    required String designation,
    required String employeeId,
    this.onNotificationIconPressed,
    this.elevation = 5.0,
  }) : type = AppBarType.profile,
       profileIcon = null,
       iconBackgroundColor = CustomAppColors.primary,
       showBackButton = false,
       showCircularBackButton = false,
       onBackButtonTapped = null,
       actions = const [],
       userDetails = '$designation • ID: $employeeId',
       subtitle = null,
       gpa = null,
       rank = null,
       totalRank = null;

  /// Creates a parent app bar configuration (shows child information)
  const AppBarConfig.parent({
    required String childInitials,
    required String childName,
    required String grade,
    required String rollNumber,
    this.onNotificationIconPressed,
    this.elevation = 5.0,
  }) : type = AppBarType.profile,
       profileIcon = null,
       iconBackgroundColor = CustomAppColors.primary,
       showBackButton = false,
       showCircularBackButton = false,
       onBackButtonTapped = null,
       actions = const [],
       userInitials = childInitials,
       userName = childName,
       userDetails = '$grade • Roll No: $rollNumber',
       subtitle = null,
       gpa = null,
       rank = null,
       totalRank = null;

  /// Creates an admin app bar configuration
  const AppBarConfig.admin({
    required String this.userInitials,
    required String this.userName,
    required String institutionName,
    this.onNotificationIconPressed,
    this.elevation = 5.0,
  }) : type = AppBarType.profile,
       profileIcon = null,
       iconBackgroundColor = CustomAppColors.primary,
       showBackButton = false,
       showCircularBackButton = false,
       onBackButtonTapped = null,
       actions = const [],
       userDetails = 'Administrator • $institutionName',
       subtitle = null,
       gpa = null,
       rank = null,
       totalRank = null;

  /// Creates a librarian app bar configuration
  const AppBarConfig.librarian({
    required String this.userInitials,
    required String this.userName,
    required String libraryName,
    this.onNotificationIconPressed,
    this.elevation = 5.0,
  }) : type = AppBarType.profile,
       profileIcon = null,
       iconBackgroundColor = CustomAppColors.primary,
       showBackButton = false,
       showCircularBackButton = false,
       onBackButtonTapped = null,
       actions = const [],
       userDetails = 'Librarian • $libraryName',
       subtitle = null,
       gpa = null,
       rank = null,
       totalRank = null;

  /// Creates a staff app bar configuration
  const AppBarConfig.staff({
    required String this.userInitials,
    required String this.userName,
    required String department,
    this.onNotificationIconPressed,
    this.elevation = 5.0,
  }) : type = AppBarType.profile,
       profileIcon = null,
       iconBackgroundColor = CustomAppColors.primary,
       showBackButton = false,
       showCircularBackButton = false,
       onBackButtonTapped = null,
       actions = const [],
       userDetails = 'Staff • $department',
       subtitle = null,
       gpa = null,
       rank = null,
       totalRank = null;

  /// Creates a super admin app bar configuration
  const AppBarConfig.superAdmin({
    required String this.userInitials,
    required String this.userName,
    required String systemName,
    this.onNotificationIconPressed,
    this.elevation = 5.0,
  }) : type = AppBarType.profile,
       profileIcon = null,
       iconBackgroundColor = CustomAppColors.primary,
       showBackButton = false,
       showCircularBackButton = false,
       onBackButtonTapped = null,
       actions = const [],
       userDetails = 'Super Administrator • $systemName',
       subtitle = null,
       gpa = null,
       rank = null,
       totalRank = null;

  /// Creates a profile-style app bar configuration with user data
  const AppBarConfig.profile({
    required Color backgroundColor,
    this.subtitle,
    this.onNotificationIconPressed,
    this.elevation = 5.0,
    this.userInitials,
    this.userName,
    this.userDetails,
    IconData? icon,
  }) : type = AppBarType.profile,
       profileIcon = icon,
       iconBackgroundColor = backgroundColor,
       showBackButton = false,
       showCircularBackButton = false,
       onBackButtonTapped = null,
       actions = const [],
       gpa = null,
       rank = null,
       totalRank = null;

  /// Creates a standard app bar configuration with back button
  const AppBarConfig.standard({
    this.showBackButton = true,
    this.showCircularBackButton = false,
    this.onBackButtonTapped,
    this.elevation = 5.0,
    this.actions = const [],
  }) : type = AppBarType.none,
       profileIcon = null,
       iconBackgroundColor = null,
       subtitle = null,
       onNotificationIconPressed = null,
       userInitials = null,
       userName = null,
       userDetails = null,
       gpa = null,
       rank = null,
       totalRank = null;

  final AppBarType type;
  final bool showBackButton;
  final bool showCircularBackButton;
  final VoidCallback? onBackButtonTapped;
  final List<Widget> actions;
  final VoidCallback? onNotificationIconPressed;
  final IconData? profileIcon;
  final String? subtitle;
  final Color? iconBackgroundColor;
  final double elevation;
  final String? userInitials;
  final String? userName;
  final String? userDetails;
  final String? gpa;
  final int? rank;
  final int? totalRank;
}

class CustomMainScreenWithAppbar extends StatelessWidget {
  const CustomMainScreenWithAppbar({
    required this.child,
    required this.title,
    super.key,
    this.appBarConfig = const AppBarConfig(),
    this.bottomWidget,
    this.floatingActionButton,
    this.bottomWidgetPadding = const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 32.0),
    this.isLoading = false,
  });

  final Widget child;
  final String title;
  final AppBarConfig appBarConfig;
  final Widget? bottomWidget;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry bottomWidgetPadding;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // Get responsive padding
    final padding = ResponsiveUtils.responsivePadding(context);

    return Stack(
      children: [
        Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
              appBarConfig.type == AppBarType.profile
                  ? kToolbarHeight + 8
                  : kToolbarHeight,
            ),
            child: _CustomAppBar(title: title, config: appBarConfig),
          ),
          bottomNavigationBar:
              bottomWidget == null
                  ? null
                  : Padding(padding: bottomWidgetPadding, child: bottomWidget),
          body: _buildResponsiveBody(context, padding),
          floatingActionButton: floatingActionButton,
        ),
        // Full-screen loader overlay
        if (isLoading)
          const Positioned.fill(
            child: UnifiedLoader(),
          ),
      ],
    );
  }

  Widget _buildResponsiveBody(BuildContext context, EdgeInsets padding) {
    // For desktop/large screens, center content with max width
    if (context.isDesktop) {
      return Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: BoxConstraints(maxWidth: context.maxContentWidth),
          padding: padding,
          child: child,
        ),
      );
    }

    // For mobile and tablet, use full width with responsive padding
    return Padding(padding: padding, child: child);
  }
}

class _CustomAppBar extends StatelessWidget {
  const _CustomAppBar({required this.title, required this.config});

  final String title;
  final AppBarConfig config;

  @override
  Widget build(BuildContext context) {
    final isProfileType = config.type == AppBarType.profile;

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: !isProfileType,
      backgroundColor: isProfileType ? Colors.white : CustomAppColors.primary,
      elevation: 0,
      surfaceTintColor: isProfileType ? Colors.white : null,
      titleSpacing: isProfileType ? 16 : null,
      toolbarHeight: isProfileType ? kToolbarHeight + 16 : kToolbarHeight,
      // Add divider for profile type
      bottom:
          isProfileType
              ? PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: Container(height: 1, color: const Color(0xFFE5E7EB)),
              )
              : null,
      // Leading (back button) - only for standard type
      leading:
          !isProfileType && config.showBackButton
              ? IconButton(
                // padding: const EdgeInsets.only(left: 16),
                icon: SvgPicture.asset(
                  'assets/images/icons/ic_back_arrow.svg',
                  width: 20,
                  alignment: Alignment.centerLeft,
                  colorFilter: const ColorFilter.mode(
                    CustomAppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  if (config.onBackButtonTapped != null) {
                    config.onBackButtonTapped?.call();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              )
              : null,
      // Title
      title:
          isProfileType
              ? Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color:
                          config.iconBackgroundColor ?? CustomAppColors.primary,
                      borderRadius: BorderRadius.circular(22.0),
                    ),
                    child:
                        config.userInitials != null
                            ? Center(
                              child: Text(
                                config.userInitials!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            : Icon(
                              config.profileIcon ?? Icons.people_outline,
                              color: Colors.white,
                              size: 32,
                            ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          config.userName ?? title,
                          style: context.textTheme.titleSm.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        if (config.userDetails != null)
                          Text(
                            config.userDetails!,
                            style: context.textTheme.bodyXs.copyWith(
                              color: const Color(0xFF666666),
                              fontSize: 14,
                            ),
                          )
                        else
                          Text(
                            config.subtitle ?? context.translate('dashboard'),
                            style: context.textTheme.bodyXs.copyWith(
                              color: const Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              )
              : Text(
                title,
                style: context.textTheme.labelBase.copyWith(
                  color: CustomAppColors.white,
                ),
              ),
      // Actions
      actions:
          isProfileType && config.onNotificationIconPressed != null
              ? [
                IconButton(
                  onPressed: config.onNotificationIconPressed,
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ]
              : config.actions,
      actionsPadding: const EdgeInsets.only(right: 12),
    );
  }
}
