import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../utils/responsive_utils.dart';
import '../models/library_models.dart';

/// Monthly Library Activity Chart
class MonthlyActivityChart extends StatelessWidget {
  const MonthlyActivityChart({required this.activityData, super.key});

  final List<MonthlyActivity>? activityData;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isDesktop = context.isDesktop;

    if (activityData == null || activityData!.isEmpty) {
      return _buildEmptyState();
    }

    // Find max value for scaling
    final maxValue = activityData!.fold<int>(
      0,
      (max, activity) => math.max(
        max,
        math.max(
          activity.issued,
          math.max(activity.returned, activity.overdue),
        ),
      ),
    );

    // Responsive sizing
    final chartHeight = isMobile ? 200.0 : (isDesktop ? 280.0 : 250.0);
    final fontSize = isMobile ? 10.0 : 12.0;
    final reservedSize = isMobile ? 28.0 : 35.0;
    final padding = isMobile ? 12.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Books issued, returned, and overdue',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 13,
              color: const Color(0xFF64748b),
            ),
          ),
          SizedBox(height: isDesktop ? 24 : 20),

          // Chart using fl_chart
          SizedBox(
            height: chartHeight,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue.toDouble() * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        var label = '';
                        if (rodIndex == 0) {
                          label = 'Issued';
                        }
                        if (rodIndex == 1) {
                          label = 'Overdue';
                        }
                        if (rodIndex == 2) {
                          label = 'Returned';
                        }

                        return BarTooltipItem(
                          '$label\n${rod.toY.toInt()}',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final style = TextStyle(
                            color: const Color(0xFF64748b),
                            fontWeight: FontWeight.w500,
                            fontSize: fontSize,
                          );
                          final index = value.toInt();
                          if (index >= 0 && index < activityData!.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 4,
                              child: Text(
                                activityData![index].month,
                                style: style,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: reservedSize,
                        getTitlesWidget: (value, meta) {
                          final style = TextStyle(
                            color: const Color(0xFF64748b),
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          );
                          return Text(value.toInt().toString(), style: style);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    border: Border.all(color: const Color(0xFFe2e8f0)),
                  ),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine:
                        (value) => const FlLine(
                          color: Color(0xFFe2e8f0),
                          strokeWidth: 1,
                        ),
                  ),
                  barGroups: List.generate(activityData!.length, (index) {
                    final activity = activityData![index];
                    final barWidth = isMobile ? 8.0 : 12.0;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: activity.issued.toDouble(),
                          color: const Color(0xFF8b5cf6),
                          width: barWidth,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: activity.overdue.toDouble(),
                          color: const Color(0xFFef4444),
                          width: barWidth,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: activity.returned.toDouble(),
                          color: const Color(0xFF10b981),
                          width: barWidth,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),

          SizedBox(height: isDesktop ? 20 : 16),

          // Legend
          Wrap(
            spacing: isDesktop ? 16 : 12,
            runSpacing: 8,
            children: [
              _buildLegendItem('Issued', const Color(0xFF8b5cf6), isMobile),
              _buildLegendItem('Overdue', const Color(0xFFef4444), isMobile),
              _buildLegendItem('Returned', const Color(0xFF10b981), isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isMobile) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: isMobile ? 12 : 14,
        height: isMobile ? 12 : 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      SizedBox(width: isMobile ? 6 : 8),
      Text(
        label,
        style: TextStyle(
          fontSize: isMobile ? 12 : 13,
          color: const Color(0xFF64748b),
        ),
      ),
    ],
  );

  Widget _buildEmptyState() => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFe2e8f0)),
    ),
    child: const Center(
      child: Text(
        'No activity data available',
        style: TextStyle(color: Color(0xFF64748b)),
      ),
    ),
  );
}

/// Category Distribution Donut Chart
class CategoryDistributionChart extends StatelessWidget {
  const CategoryDistributionChart({required this.categoryData, super.key});

  final List<CategoryDistribution>? categoryData;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isDesktop = context.isDesktop;

    if (categoryData == null || categoryData!.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribution by category',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 13,
              color: const Color(0xFF64748b),
            ),
          ),
          SizedBox(height: isDesktop ? 24 : 20),

          // Donut Chart and Labels
          Row(
            children: [
              // Donut Chart using fl_chart
              SizedBox(
                width: isMobile ? 160 : 200,
                height: isMobile ? 160 : 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: isMobile ? 50 : 65,
                    sections:
                        categoryData!
                            .map(
                              (category) => PieChartSectionData(
                                color: category.color,
                                value: category.percentage,
                                title: '',
                                radius: isMobile ? 30 : 35,
                                titleStyle: const TextStyle(
                                  fontSize: 0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                            .toList(),
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        // Handle touch events if needed
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(width: isMobile ? 20 : 32),

              // Labels
              Expanded(
                child: Wrap(
                  spacing: isDesktop ? 16 : 12,
                  runSpacing: isDesktop ? 16 : 12,
                  children:
                      categoryData!
                          .map(
                            (category) => _buildCategoryLabel(
                              category.category,
                              category.percentage,
                              category.color,
                              isMobile,
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLabel(
    String label,
    double percentage,
    Color color,
    bool isMobile,
  ) => SizedBox(
    width: isMobile ? 140 : 160,
    child: Row(
      children: [
        Container(
          width: isMobile ? 12 : 14,
          height: isMobile ? 12 : 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: isMobile ? 8 : 10),
        Expanded(
          child: Text(
            '$label ${percentage.toInt()}%',
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _buildEmptyState() => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFe2e8f0)),
    ),
    child: const Center(
      child: Text(
        'No category data available',
        style: TextStyle(color: Color(0xFF64748b)),
      ),
    ),
  );
}
