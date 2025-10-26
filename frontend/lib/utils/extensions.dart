import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_theme.dart';
import 'localization/app_localizations.dart';

extension BuildContextLocalizationExtension on BuildContext {
  String translate(String key, {Map<String, dynamic>? params}) =>
      AppLocalizations.of(this)?.translate(key, params: params) ?? key;
}

extension CustomTextTheme on TextTheme {
  // Heading styles using new typography scale
  // h1 - 3xl/30px Bold (Large headings)
  TextStyle get h1 => GoogleFonts.inter(
    fontSize: AppTheme.fontSize3xl,
    fontWeight: AppTheme.fontWeightBold,
    height: 1.3,
  );

  // h2 - 2xl/24px Bold (Page titles)
  TextStyle get h2 => GoogleFonts.inter(
    fontSize: AppTheme.fontSize2xl,
    fontWeight: AppTheme.fontWeightBold,
    height: 1.3,
  );

  // h3 - xl/20px Semibold (Section headings)
  TextStyle get h3 => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeXl,
    fontWeight: AppTheme.fontWeightSemibold,
    height: 1.3,
  );

  // h4 - lg/18px Semibold (Card titles)
  TextStyle get h4 => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeLg,
    fontWeight: AppTheme.fontWeightSemibold,
    height: 1.3,
  );

  // h5 - base/16px Semibold (Small headings)
  TextStyle get h5 => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeBase,
    fontWeight: AppTheme.fontWeightSemibold,
    height: 1.3,
  );

  // Body text styles - Normal weight (400)
  TextStyle get bodyXl => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeXl,
    fontWeight: AppTheme.fontWeightNormal,
    height: 1.8,
  );

  TextStyle get bodyLg => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeLg,
    fontWeight: AppTheme.fontWeightNormal,
    height: 1.8,
  );

  TextStyle get bodyBase => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeBase,
    fontWeight: AppTheme.fontWeightNormal,
    height: 1.8,
  );

  TextStyle get bodySm => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeSm,
    fontWeight: AppTheme.fontWeightNormal,
    height: 1.8,
  );

  TextStyle get bodyXs => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeXs,
    fontWeight: AppTheme.fontWeightNormal,
    height: 1.8,
  );

  // Medium weight text (500) - for buttons, labels
  TextStyle get labelXl => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeXl,
    fontWeight: AppTheme.fontWeightMedium,
    height: 1.3,
  );

  TextStyle get labelLg => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeLg,
    fontWeight: AppTheme.fontWeightMedium,
    height: 1.3,
  );

  TextStyle get labelBase => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeBase,
    fontWeight: AppTheme.fontWeightMedium,
    height: 1.3,
  );

  TextStyle get labelSm => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeSm,
    fontWeight: AppTheme.fontWeightMedium,
    height: 1.3,
  );

  TextStyle get labelXs => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeXs,
    fontWeight: AppTheme.fontWeightMedium,
    height: 1.3,
  );

  // Semibold text (600) - for card titles, emphasis
  TextStyle get titleXl => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeXl,
    fontWeight: AppTheme.fontWeightSemibold,
    height: 1.3,
  );

  TextStyle get titleLg => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeLg,
    fontWeight: AppTheme.fontWeightSemibold,
    height: 1.3,
  );

  TextStyle get titleBase => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeBase,
    fontWeight: AppTheme.fontWeightSemibold,
    height: 1.3,
  );

  TextStyle get titleSm => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeSm,
    fontWeight: AppTheme.fontWeightSemibold,
    height: 1.3,
  );

  TextStyle get titleXs => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeXs,
    fontWeight: AppTheme.fontWeightSemibold,
    height: 1.3,
  );

  // Bold text (700) - for important headings
  TextStyle get display3xl => GoogleFonts.inter(
    fontSize: AppTheme.fontSize3xl,
    fontWeight: AppTheme.fontWeightBold,
    height: 1.3,
  );

  TextStyle get display2xl => GoogleFonts.inter(
    fontSize: AppTheme.fontSize2xl,
    fontWeight: AppTheme.fontWeightBold,
    height: 1.3,
  );

  TextStyle get displayXl => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeXl,
    fontWeight: AppTheme.fontWeightBold,
    height: 1.3,
  );

  TextStyle get displayLg => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeLg,
    fontWeight: AppTheme.fontWeightBold,
    height: 1.3,
  );

  TextStyle get displayBase => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeBase,
    fontWeight: AppTheme.fontWeightBold,
    height: 1.3,
  );

  TextStyle get displaySm => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeSm,
    fontWeight: AppTheme.fontWeightBold,
    height: 1.3,
  );
}

extension ContextExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}
