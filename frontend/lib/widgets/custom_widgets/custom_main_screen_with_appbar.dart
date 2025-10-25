// import 'package:ed_verse/utils/custom_colors.dart';
// import 'package:ed_verse/utils/custom_images.dart';
// import 'package:ed_verse/utils/enum.dart';
// import 'package:ed_verse/utils/extensions.dart';
// import 'package:ed_verse/utils/images/base_image.dart';
// import 'package:ed_verse/utils/images/image_asset.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class CustomMainScreenWithAppbar extends StatelessWidget {
//   final Widget child, appbarAction;
//   final String title;
//   final void Function()? onBackButtonTapped;
//   final bool showCircularBackButton, showBackButton;
//   final AppBarType appBarType;
//   final void Function()? onNotificationIconPressed;

//   const CustomMainScreenWithAppbar({
//     super.key,
//     required this.child,
//     required this.title,
//     this.appbarAction = const SizedBox.shrink(),
//     this.onBackButtonTapped,
//     this.showCircularBackButton = false,
//     this.showBackButton = true,
//     this.appBarType = AppBarType.none,
//     this.onNotificationIconPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(kToolbarHeight),
//         child: _CustomAppBar(
//           showBackButton: showBackButton,
//           onBackButtonTapped: onBackButtonTapped,
//           showCircularBackButton: showCircularBackButton,
//           title: title,
//           appbarAction: appbarAction,
//           appBarType: appBarType,
//           onNotificationIconPressed: onNotificationIconPressed,
//         ),
//       ),
//       body: Padding(padding: const EdgeInsets.all(16.0), child: child),
//     );
//   }
// }

// class _CustomAppBar extends StatelessWidget {
//   const _CustomAppBar({
//     required this.showBackButton,
//     required this.onBackButtonTapped,
//     required this.showCircularBackButton,
//     required this.title,
//     required this.appbarAction,
//     required this.appBarType,
//     required this.onNotificationIconPressed,
//   });

//   final bool showBackButton;
//   final void Function()? onBackButtonTapped;
//   final bool showCircularBackButton;
//   final String title;
//   final Widget appbarAction;
//   final AppBarType appBarType;
//   final void Function()? onNotificationIconPressed;

//   @override
//   Widget build(BuildContext context) {
//     return appBarType == AppBarType.profile
//         ? _CustomAppBarWithProfileDetail(
//           userName: title,
//           onNotificationIconPressed: onNotificationIconPressed,
//         )
//         : AppBar(
//           automaticallyImplyLeading: false,
//           toolbarHeight: 80,
//           bottom: PreferredSize(
//             preferredSize: Size.fromHeight(0),
//             child: Divider(color: Color(0xFFF3F3F3)),
//           ),
//           title: ColoredBox(
//             color: Colors.red,
//             child: Row(
//               children: [
//                 Visibility(
//                   visible: showBackButton,
//                   child: InkWell(
//                     onTap: () {
//                       if (onBackButtonTapped != null) {
//                         onBackButtonTapped?.call();
//                       } else {
//                         Navigator.of(context).pop();
//                       }
//                     },
//                     child:
//                         showCircularBackButton == false
//                             ? Padding(
//                               padding: const EdgeInsets.only(
//                                 top: 10.0,
//                                 bottom: 10.0,
//                                 right: 10.0,
//                               ),
//                               child: Icon(Icons.arrow_back, size: 25),
//                             )
//                             : SvgPicture.asset(
//                               'assets/images/ic_back_arrow_in_circle.svg',
//                               width: 50,
//                               alignment: Alignment.centerLeft,
//                             ),
//                   ),
//                 ),
//                 Spacer(),
//                 Text(title, style: context.textTheme.pm16),
//                 Spacer(flex: showBackButton ? 2 : 1),
//                 appbarAction,
//               ],
//             ),
//           ),
//         );
//   }
// }

// class _CustomAppBarWithProfileDetail extends StatelessWidget {
//   final String userName;
//   final bool? showBadge;
//   final void Function()? onNotificationIconPressed;

//   const _CustomAppBarWithProfileDetail({
//     required this.userName,
//     required this.onNotificationIconPressed,
//     this.showBadge,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: ListTile(
//         contentPadding: const EdgeInsets.all(0),
//         title: Transform.translate(
//           offset: Offset(-10, 0),
//           child: Text(userName, style: context.textTheme.psb14),
//         ),
//         subtitle: Transform.translate(
//           offset: Offset(-10, -3),
//           child: Text(
//             'subtitle',
//             style: context.textTheme.pr12.copyWith(
//               color: CustomAppColors.black03,
//             ),
//           ),
//         ),
//         leading: CircleAvatar(backgroundImage: AssetImage(CustomImages.logo)),
//       ),
//       actions: [
//         IconButton(
//           onPressed: onNotificationIconPressed,
//           icon: Badge(
//             isLabelVisible: showBadge ?? false,
//             child: BaseImage(
//               asset: LocalAsset(url: CustomImages.iconNotification),
//               height: 25,
//               width: 25,
//               color: CustomAppColors.black01,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/custom_colors.dart';
import '../../utils/custom_images.dart';
import '../../utils/enum.dart';
import '../../utils/extensions.dart';
import '../../utils/images/base_image.dart';
import '../../utils/images/image_asset.dart';
import '../../utils/responsive_utils.dart';

class CustomMainScreenWithAppbar extends StatelessWidget {
  const CustomMainScreenWithAppbar({
    required this.child,
    required this.title,
    super.key,
    this.appbarAction = const [],
    this.onBackButtonTapped,
    this.bottomWidget,
    this.bottomWidgetPadding = const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 32.0),
    this.showCircularBackButton = false,
    this.showBackButton = true,
    this.appBarType = AppBarType.none,
    this.onNotificationIconPressed,
  });
  final Widget child;
  final Widget? bottomWidget;
  final List<Widget> appbarAction;
  final String title;
  final void Function()? onBackButtonTapped;
  final bool showCircularBackButton, showBackButton;
  final AppBarType appBarType;
  final void Function()? onNotificationIconPressed;
  final EdgeInsetsGeometry bottomWidgetPadding;

  @override
  Widget build(BuildContext context) {
    // Get responsive padding
    final padding = ResponsiveUtils.responsivePadding(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _CustomAppBar(
          showBackButton: showBackButton,
          onBackButtonTapped: onBackButtonTapped,
          showCircularBackButton: showCircularBackButton,
          title: title,
          appbarAction: appbarAction,
          appBarType: appBarType,
          onNotificationIconPressed: onNotificationIconPressed,
        ),
      ),
      bottomNavigationBar:
          bottomWidget == null
              ? null
              : Padding(padding: bottomWidgetPadding, child: bottomWidget),
      body: _buildResponsiveBody(context, padding),
    );
  }

  Widget _buildResponsiveBody(BuildContext context, EdgeInsets padding) {
    // For desktop/large screens, center content with max width
    if (context.isDesktop) {
      return Center(
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
  const _CustomAppBar({
    required this.showBackButton,
    required this.onBackButtonTapped,
    required this.showCircularBackButton,
    required this.title,
    required this.appbarAction,
    required this.appBarType,
    required this.onNotificationIconPressed,
  });

  final bool showBackButton;
  final void Function()? onBackButtonTapped;
  final bool showCircularBackButton;
  final String title;
  final List<Widget> appbarAction;
  final AppBarType appBarType;
  final void Function()? onNotificationIconPressed;

  @override
  Widget build(BuildContext context) {
    if (appBarType == AppBarType.profile) {
      return _CustomAppBarWithProfileDetail(
        userName: title,
        onNotificationIconPressed: onNotificationIconPressed,
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: Divider(color: Color(0xFFF3F3F3)),
      ),
      leading:
          showBackButton
              ? IconButton(
                padding: const EdgeInsets.only(left: 16),
                icon: SvgPicture.asset(
                  showCircularBackButton
                      ? 'assets/images/icons/ic_back_arrow_in_circle.svg'
                      : 'assets/images/icons/ic_back_arrow.svg',
                  width: 60,
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  if (onBackButtonTapped != null) {
                    onBackButtonTapped?.call();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              )
              : null,
      title: Text(title, style: context.textTheme.labelBase),
      actions: appbarAction,
      actionsPadding: const EdgeInsets.only(right: 12),
    );
  }
}

class _CustomAppBarWithProfileDetail extends StatelessWidget {
  const _CustomAppBarWithProfileDetail({
    required this.userName,
    required this.onNotificationIconPressed,
    this.showBadge,
  });

  final String userName;
  final bool? showBadge;
  final void Function()? onNotificationIconPressed;

  @override
  Widget build(BuildContext context) => AppBar(
    title: ListTile(
      contentPadding: EdgeInsets.zero,
      title: Transform.translate(
        offset: const Offset(-10, 0),
        child: Text(userName, style: context.textTheme.titleSm),
      ),
      subtitle: Transform.translate(
        offset: const Offset(-10, -3),
        child: Text(
          'subtitle',
          style: context.textTheme.bodyXs.copyWith(
            color: CustomAppColors.black03,
          ),
        ),
      ),
      leading: const CircleAvatar(
        backgroundImage: AssetImage(CustomImages.appLogo),
      ),
    ),
    actions: [
      IconButton(
        onPressed: onNotificationIconPressed,
        icon: Badge(
          isLabelVisible: showBadge ?? false,
          child: BaseImage(
            asset: LocalAsset(url: CustomImages.iconNotification),
            height: 25,
            width: 25,
            color: CustomAppColors.black01,
          ),
        ),
      ),
    ],
  );
}
