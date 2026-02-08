import 'package:flutter/material.dart';

import '../../../../utils/custom_colors.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class FeePaymentScreen extends StatelessWidget {
  const FeePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock parent/child data
    const childInitials = 'AS';
    const childName = 'Alice Smith';
    const grade = 'Class 10';
    const rollNumber = '23';

    return CustomMainScreenWithAppbar(
      title: 'Fee Payment',
      appBarConfig: AppBarConfig.parent(
        childInitials: childInitials,
        childName: childName,
        grade: grade,
        rollNumber: rollNumber,
        onNotificationIconPressed: () {},
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const ColoredBox(
              color: Colors.white,
              child: TabBar(
                labelColor: CustomAppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: CustomAppColors.primary,
                tabs: [Tab(text: 'Pending'), Tab(text: 'Paid')],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFeeList(context, false),
                  _buildFeeList(context, true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeList(BuildContext context, bool isPaid) {
    final fees =
        isPaid
            ? [
              {
                'title': 'Admission Fee',
                'amount': r'$500',
                'date': 'Paid on Jan 10',
                'status': 'Paid',
              },
              {
                'title': 'Term 1 Tuition',
                'amount': r'$1200',
                'date': 'Paid on Mar 15',
                'status': 'Paid',
              },
            ]
            : [
              {
                'title': 'Term 2 Tuition',
                'amount': r'$1200',
                'date': 'Due: Oct 30',
                'status': 'Pending',
              },
              {
                'title': 'Lab Fee',
                'amount': r'$150',
                'date': 'Due: Nov 15',
                'status': 'Pending',
              },
            ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fees.length,
      itemBuilder: (context, index) {
        final item = fees[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      item['amount']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: CustomAppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['date']!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    if (!isPaid)
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomAppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Pay Now'),
                      )
                    else
                      const Chip(
                        label: Text(
                          'Paid',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
