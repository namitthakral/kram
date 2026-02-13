import 'package:kram/provider/theme_provider.dart';
import 'package:kram/widgets/custom_widgets/custom_date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('CustomDatePickerField handles selectedDate outside allowed range', (WidgetTester tester) async {
    // Setup - define dates
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));

    // We want to test the case where:
    // firstDate is tomorrow (future only)
    // selectedDate is yesterday (past date, e.g. from existing record)
    // This would normally crash showDatePicker if initialDate (yesterday) < firstDate (tomorrow)

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CustomDatePickerField(
              label: 'Test Date Picker',
              onDateSelected: (date) {},
              selectedDate: yesterday,
              firstDate: tomorrow,
              lastDate: now.add(const Duration(days: 30)),
            ),
          ),
        ),
      ),
    );

    // Act - tap the date picker - target the InkWell specifically
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    // Assert - Verify date picker appeared
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
