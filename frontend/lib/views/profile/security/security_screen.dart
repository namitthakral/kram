import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../provider/profile/security/security_provider.dart';
import '../../../utils/app_bar_config_helper.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(context.translate('user_not_found'))),
      );
    }

    return CustomMainScreenWithAppbar(
      title: context.translate('security'),
      appBarConfig: AppBarConfigHelper.getConfigForUser(
        user,
        onNotificationIconPressed: () {},
        isProfileScreen: true,
      ),
      child: Consumer<ProfileSecurityProvider>(
      builder:
          (context, profileSecurityProvider, child) => Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE3E7EC)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text(context.translate('face_id')),
                  value: profileSecurityProvider.faceId,
                  onChanged:
                      (val) => profileSecurityProvider.setFaceId(faceId: val),
                ),
                const Divider(indent: 16.0, endIndent: 16.0),
                SwitchListTile(
                  title: Text(context.translate('remember_password')),
                  value: profileSecurityProvider.rememberPassword,
                  onChanged:
                      (val) => profileSecurityProvider.setRememberPassword(
                        rememberPassword: val,
                      ),
                ),
                const Divider(indent: 16.0, endIndent: 16.0),
                SwitchListTile(
                  title: Text(context.translate('touch_id')),
                  value: profileSecurityProvider.touchId,
                  onChanged:
                      (val) => profileSecurityProvider.setTouchId(touchId: val),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
