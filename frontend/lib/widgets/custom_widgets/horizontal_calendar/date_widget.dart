import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../provider/theme_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import 'date_helper.dart';

class DateWidget extends StatelessWidget {
  const DateWidget({
    required this.date,
    super.key,
    this.onTap,
    this.onLongTap,
    this.isTodayDate = false,
    this.isSelected = false,
    this.isDisabled = false,
    this.isLabelUppercase = false,
    this.monthTextStyle,
    this.selectedMonthTextStyle,
    this.monthFormat,
    this.dateTextStyle,
    this.selectedDateTextStyle,
    this.dateFormat,
    this.weekDayTextStyle,
    this.selectedWeekDayTextStyle,
    this.weekDayFormat,
    this.defaultDecoration,
    this.selectedDecoration = const BoxDecoration(color: Colors.cyan),
    this.disabledDecoration = const BoxDecoration(color: Colors.grey),
    this.padding,
    this.labelOrder,
  });
  final defaultDateFormat = 'dd';
  final defaultMonthFormat = 'MMM';
  final defaultWeekDayFormat = 'EEE';

  final DateTime date;
  final bool isSelected, isTodayDate, isLabelUppercase, isDisabled;
  final TextStyle? monthTextStyle,
      selectedMonthTextStyle,
      dateTextStyle,
      selectedDateTextStyle,
      weekDayTextStyle,
      selectedWeekDayTextStyle;
  final String? monthFormat, weekDayFormat, dateFormat;
  final VoidCallback? onTap;
  final VoidCallback? onLongTap;
  final Decoration? defaultDecoration;
  final Decoration? selectedDecoration;
  final Decoration? disabledDecoration;
  final EdgeInsetsGeometry? padding;
  final List<LabelType>? labelOrder;

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeProvider>().themeData;

    final titleStyle = context.textTheme.displayLg;
    final subTitleStyle = context.textTheme.bodySm;

    final dateStyle =
        isSelected
            ? selectedDateTextStyle ?? dateTextStyle ?? titleStyle
            : dateTextStyle ?? titleStyle;
    final dayStyle =
        isSelected
            ? selectedWeekDayTextStyle ?? weekDayTextStyle ?? subTitleStyle
            : weekDayTextStyle ?? subTitleStyle;

    // Get responsive padding
    final responsivePadding = padding ??
        ResponsiveUtils.responsive<EdgeInsets>(
          context: context,
          mobile: const EdgeInsets.all(4),
          tablet: const EdgeInsets.all(6),
          desktop: const EdgeInsets.all(8),
        );

    // Get responsive spacing
    final spacing = ResponsiveUtils.responsive<double>(
      context: context,
      mobile: 8,
      tablet: 10,
      desktop: 12,
    );

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      onLongPress: isDisabled ? null : onLongTap,
      child: DecoratedBox(
        decoration:
            (isSelected
                ? selectedDecoration
                : isDisabled
                ? disabledDecoration
                : defaultDecoration) ??
            const BoxDecoration(),
        child: Padding(
          padding: responsivePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLabelUppercase
                    ? _weekDayLabel().toUpperCase()
                    : _weekDayLabel(),
                style:
                    isSelected
                        ? TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        )
                        : dayStyle,
              ),
              SizedBox(height: spacing),
              Center(
                child: Text(
                  DateFormat(dateFormat ?? defaultDateFormat).format(date),
                  style: dateStyle.copyWith(
                    color:
                        isSelected
                            ? CustomAppColors.white
                            : CustomAppColors.black01,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _weekDayLabel() =>
      date.day == DateTime.now().day &&
              date.month == DateTime.now().month &&
              date.year == DateTime.now().year
          ? 'Today'
          : DateFormat(weekDayFormat ?? defaultWeekDayFormat).format(date);
}
