import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/bottom_nav_provider.dart';
import '../../provider/language_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomMainScreenWithAppbar(
    title: context.translate('language'),
    appBarConfig: const AppBarConfig.standard(
      showCircularBackButton: true,
    ),
    child: Consumer<LanguageProvider>(
      builder:
          (context, value, child) => Column(
            children: [
              const SizedBox(height: 16),
              _CustomTile(title: context.translate('english'), flag: 'en'),
              const SizedBox(height: 16),
              _CustomTile(title: context.translate('hindi'), flag: 'hi'),
            ],
          ),
    ),
  );
}

class _CustomTile extends StatelessWidget {
  const _CustomTile({required this.title, required this.flag});
  final String title, flag;

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.read<LanguageProvider>();
    final isSelected = languageProvider.locale.languageCode == flag;

    return ListTile(
      title: Text(title, style: context.textTheme.labelSm),
      leading: Image.asset(
        'assets/images/language/$flag.png',
        height: 30,
        width: 30,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFFF39C12) : const Color(0xFFF3F3F3),
        ),
      ),
      trailing:
          isSelected ? const Icon(Icons.check, color: Color(0xFFF39C12)) : null,
      onTap: () {
        languageProvider.setLocale(flag);
        context.read<BottomNavProvider>().setIndex(0);
      },
    );
  }
}
