import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/language_provider.dart';
import '../../../utils/extensions.dart';

class LanguageTab extends StatelessWidget {
  const LanguageTab({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          context,
          title: 'Select Language',
          children: [
            Consumer<LanguageProvider>(
              builder:
                  (context, languageProvider, child) => Column(
                    children: [
                      _LanguageTile(
                        title: context.translate('english'),
                        flag: 'en',
                        isSelected:
                            languageProvider.locale.languageCode == 'en',
                        onTap: () {
                          languageProvider.setLocale('en');
                          context.go('/dashboard');
                        },
                      ),
                      const SizedBox(height: 16),
                      _LanguageTile(
                        title: context.translate('hindi'),
                        flag: 'hi',
                        isSelected:
                            languageProvider.locale.languageCode == 'hi',
                        onTap: () {
                          languageProvider.setLocale('hi');
                          context.go('/dashboard');
                        },
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.slate100),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.slate800,
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    ),
  );
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppTheme.slate100,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isSelected ? AppTheme.warning : AppTheme.slate100,
        width: isSelected ? 2 : 1,
      ),
    ),
    child: ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: AppTheme.slate800,
        ),
      ),
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.slate100),
        ),
        child: Image.asset(
          'assets/images/language/$flag.png',
          height: 30,
          width: 30,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.language, size: 30),
        ),
      ),
      trailing:
          isSelected
              ? const Icon(Icons.check_circle, color: AppTheme.warning)
              : const Icon(Icons.circle_outlined, color: AppTheme.slate500),
      onTap: onTap,
    ),
  );
}
