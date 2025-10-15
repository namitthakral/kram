import 'package:flutter/material.dart';

import 'date_helper.dart';
import 'date_widget.dart';

typedef DateBuilder = bool Function(DateTime dateTime);

typedef DateSelectionCallBack = void Function(DateTime dateTime);

class HorizontalCalendar extends StatefulWidget {
  HorizontalCalendar({
    required this.firstDate,
    required this.lastDate,
    super.key,
    this.height = 100,
    this.scrollController,
    this.onDateSelected,
    this.onDateLongTap,
    this.onDateUnSelected,
    this.onMaxDateSelectionReached,
    this.minSelectedDateCount = 0,
    this.maxSelectedDateCount = 1,
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
    this.selectedDecoration,
    this.disabledDecoration,
    this.isDateDisabled,
    this.initialSelectedDates = const [],
    this.spacingBetweenDates = 8.0,
    this.isTodayDate = false,
    this.padding = const EdgeInsets.all(8.0),
    this.labelOrder = const [
      LabelType.month,
      LabelType.date,
      LabelType.weekday,
    ],
    this.isLabelUppercase = false,
  }) : assert(
         toDateMonthYear(lastDate) == toDateMonthYear(firstDate) ||
             toDateMonthYear(lastDate).isAfter(toDateMonthYear(firstDate)),
       ),
       assert(
         labelOrder != null && labelOrder.isNotEmpty,
         'Label Order should not be empty',
       ),
       assert(minSelectedDateCount <= maxSelectedDateCount),
       assert(
         minSelectedDateCount <= initialSelectedDates.length,
         'You must provide at least $minSelectedDateCount initialSelectedDates',
       ),
       assert(
         maxSelectedDateCount >= initialSelectedDates.length,
         "You can't provide more than $maxSelectedDateCount initialSelectedDates",
       );
  final DateTime firstDate, lastDate;
  final TextStyle? monthTextStyle,
      selectedMonthTextStyle,
      dateTextStyle,
      selectedDateTextStyle,
      weekDayTextStyle,
      selectedWeekDayTextStyle;
  final String? dateFormat, monthFormat, weekDayFormat;
  final DateSelectionCallBack? onDateSelected, onDateLongTap, onDateUnSelected;
  final VoidCallback? onMaxDateSelectionReached;
  final Decoration? defaultDecoration, selectedDecoration, disabledDecoration;
  final DateBuilder? isDateDisabled;
  final List<DateTime> initialSelectedDates;
  final ScrollController? scrollController;
  final double? height, spacingBetweenDates;
  final EdgeInsetsGeometry? padding;
  final List<LabelType>? labelOrder;
  final int minSelectedDateCount, maxSelectedDateCount;
  final bool isLabelUppercase, isTodayDate;

  @override
  _HorizontalCalendarState createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalCalendar> {
  final List<DateTime> allDates = [];
  final List<DateTime> selectedDates = [];

  @override
  void initState() {
    super.initState();
    allDates.addAll(getDateList(widget.firstDate, widget.lastDate));
    selectedDates.addAll(widget.initialSelectedDates.map(toDateMonthYear));
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: widget.height,
    child: Center(
      child: ListView.builder(
        controller: widget.scrollController ?? ScrollController(),
        scrollDirection: Axis.horizontal,
        itemCount: allDates.length,
        itemBuilder: (context, index) {
          final date = allDates[index];
          return Row(
            children: <Widget>[
              DateWidget(
                key: Key(date.toIso8601String()),
                padding: widget.padding,
                isSelected: selectedDates.contains(date),
                isDisabled:
                    widget.isDateDisabled != null
                        ? widget.isDateDisabled!(date)
                        : false,
                date: date,
                isTodayDate: widget.isTodayDate,
                monthTextStyle: widget.monthTextStyle,
                selectedMonthTextStyle: widget.selectedMonthTextStyle,
                monthFormat: widget.monthFormat,
                dateTextStyle: widget.dateTextStyle,
                selectedDateTextStyle: widget.selectedDateTextStyle,
                dateFormat: widget.dateFormat,
                weekDayTextStyle: widget.weekDayTextStyle,
                selectedWeekDayTextStyle: widget.selectedWeekDayTextStyle,
                weekDayFormat: widget.weekDayFormat,
                defaultDecoration: widget.defaultDecoration,
                selectedDecoration: widget.selectedDecoration,
                disabledDecoration: widget.disabledDecoration,
                labelOrder: widget.labelOrder,
                isLabelUppercase: widget.isLabelUppercase,
                onTap: () {
                  if (!selectedDates.contains(date)) {
                    if (widget.maxSelectedDateCount == 1 &&
                        selectedDates.length == 1) {
                      selectedDates.clear();
                    } else if (widget.maxSelectedDateCount ==
                        selectedDates.length) {
                      if (widget.onMaxDateSelectionReached != null) {
                        widget.onMaxDateSelectionReached!();
                      }
                      return;
                    }

                    selectedDates.add(date);
                    if (widget.onDateSelected != null) {
                      widget.onDateSelected!(date);
                    }
                    setState(() {});
                  }

                  //De-select date
                  //  else if (selectedDates.length >
                  //     widget.minSelectedDateCount) {
                  //   final isRemoved = selectedDates.remove(date);
                  //   if (isRemoved && widget.onDateUnSelected != null) {
                  //     widget.onDateUnSelected!(date);
                  //   }
                  // }
                },
                onLongTap:
                    () =>
                        widget.onDateLongTap != null
                            ? widget.onDateLongTap!(date)
                            : null,
              ),
              SizedBox(width: widget.spacingBetweenDates),
            ],
          );
        },
      ),
    ),
  );
}
