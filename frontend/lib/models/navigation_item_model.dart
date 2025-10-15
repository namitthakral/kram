import '../utils/custom_images.dart';

/// Navigation item data model
/// Shared between CustomBottomNavBar and CustomNavigationDrawer
class NavigationItemModel {
  const NavigationItemModel({
    required this.iconUrl,
    required this.iconFilledUrl,
    required this.labelKey,
  });

  final String iconUrl;
  final String iconFilledUrl;
  final String labelKey;
}

/// Shared navigation items configuration
/// Used by both mobile bottom navigation and desktop drawer
class NavigationItems {
  NavigationItems._();

  static const List<NavigationItemModel> items = [
    NavigationItemModel(
      iconUrl: CustomImages.iconHome,
      iconFilledUrl: CustomImages.iconHomeFilled,
      labelKey: 'home',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconSchedule,
      iconFilledUrl: CustomImages.iconScheduleFilled,
      labelKey: 'schedule',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconShoppingCart,
      iconFilledUrl: CustomImages.iconShoppingCartFilled,
      labelKey: 'store',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconMessage,
      iconFilledUrl: CustomImages.iconMessageFilled,
      labelKey: 'message',
    ),
    NavigationItemModel(
      iconUrl: CustomImages.iconProfile,
      iconFilledUrl: CustomImages.iconProfileFilled,
      labelKey: 'profile',
    ),
  ];
}
