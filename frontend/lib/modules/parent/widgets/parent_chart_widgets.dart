import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../utils/responsive_utils.dart';
import '../models/parent_dashboard_models.dart';

/// Performance Trends Chart
class ParentPerformanceTrendsChart extends StatelessWidget {
  const ParentPerformanceTrendsChart({required this.trendsData, super.key});

  final List<PerformanceTrendPoint> trendsData;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    if (trendsData.isEmpty) {
      return const Center(child: Text('No performance data available'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Get responsive dimensions
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobileScreen = screenWidth < 600;
        final isTabletScreen = screenWidth >= 600 && screenWidth < 900;

        // Responsive sizing
        final chartHeight =
            isMobileScreen ? 220.0 : (isTabletScreen ? 280.0 : 320.0);
        final fontSize = isMobileScreen ? 10.0 : 12.0;
        final reservedSize = isMobileScreen ? 28.0 : 35.0;
        final dotRadius = isMobileScreen ? 3.0 : 4.0;
        final lineWidth = isMobileScreen ? 2.5 : 3.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Performance Trends',
              style: TextStyle(
                fontSize: isMobile ? 17 : 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1e293b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Academic progress across major subjects',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: const Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: chartHeight,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine:
                        (value) => const FlLine(
                          color: Color(0xFFe2e8f0),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        reservedSize: reservedSize,
                        getTitlesWidget:
                            (value, meta) => Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: const Color(0xFF64748b),
                                fontSize: fontSize,
                              ),
                            ),
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < trendsData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                trendsData[value.toInt()].month,
                                style: TextStyle(
                                  color: const Color(0xFF64748b),
                                  fontSize: fontSize,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    // English line
                    LineChartBarData(
                      spots:
                          trendsData
                              .asMap()
                              .entries
                              .map(
                                (e) =>
                                    FlSpot(e.key.toDouble(), e.value.english),
                              )
                              .toList(),
                      isCurved: true,
                      color: const Color(0xFFf59e0b),
                      barWidth: lineWidth,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        getDotPainter:
                            (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: dotRadius,
                                  color: const Color(0xFFf59e0b),
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                      ),
                      belowBarData: BarAreaData(),
                    ),
                    // Mathematics line
                    LineChartBarData(
                      spots:
                          trendsData
                              .asMap()
                              .entries
                              .map(
                                (e) => FlSpot(
                                  e.key.toDouble(),
                                  e.value.mathematics,
                                ),
                              )
                              .toList(),
                      isCurved: true,
                      color: const Color(0xFF4F7CFF),
                      barWidth: lineWidth,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        getDotPainter:
                            (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: dotRadius,
                                  color: const Color(0xFF4F7CFF),
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                      ),
                      belowBarData: BarAreaData(),
                    ),
                    // Science line
                    LineChartBarData(
                      spots:
                          trendsData
                              .asMap()
                              .entries
                              .map(
                                (e) =>
                                    FlSpot(e.key.toDouble(), e.value.science),
                              )
                              .toList(),
                      isCurved: true,
                      color: const Color(0xFF10b981),
                      barWidth: lineWidth,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        getDotPainter:
                            (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: dotRadius,
                                  color: const Color(0xFF10b981),
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                      ),
                      belowBarData: BarAreaData(),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems:
                          (touchedSpots) =>
                              touchedSpots.map((spot) {
                                var subject = '';
                                var color = Colors.black;
                                if (spot.barIndex == 0) {
                                  subject = 'English';
                                  color = const Color(0xFFf59e0b);
                                } else if (spot.barIndex == 1) {
                                  subject = 'Mathematics';
                                  color = const Color(0xFF4F7CFF);
                                } else {
                                  subject = 'Science';
                                  color = const Color(0xFF10b981);
                                }
                                return LineTooltipItem(
                                  '$subject: ${spot.y.toInt()}%',
                                  TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSize,
                                  ),
                                );
                              }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            const Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _LegendItem(color: Color(0xFFf59e0b), label: 'English'),
                _LegendItem(color: Color(0xFF4F7CFF), label: 'Mathematics'),
                _LegendItem(color: Color(0xFF10b981), label: 'Science'),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Attendance Trends Chart
class ParentAttendanceTrendsChart extends StatelessWidget {
  const ParentAttendanceTrendsChart({required this.trendsData, super.key});

  final List<AttendanceTrendPoint> trendsData;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    if (trendsData.isEmpty) {
      return const Center(child: Text('No attendance data available'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Get responsive dimensions
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobileScreen = screenWidth < 600;
        final isTabletScreen = screenWidth >= 600 && screenWidth < 900;

        // Responsive sizing
        final chartHeight =
            isMobileScreen ? 200.0 : (isTabletScreen ? 250.0 : 280.0);
        final fontSize = isMobileScreen ? 10.0 : 12.0;
        final reservedSize = isMobileScreen ? 32.0 : 40.0;
        final barWidth = isMobileScreen ? 20.0 : (isTabletScreen ? 26.0 : 32.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Trends',
              style: TextStyle(
                fontSize: isMobile ? 17 : 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1e293b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Monthly attendance percentage',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: const Color(0xFF64748b),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: chartHeight,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine:
                        (value) => const FlLine(
                          color: Color(0xFFe2e8f0),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        reservedSize: reservedSize,
                        getTitlesWidget:
                            (value, meta) => Text(
                              '${value.toInt()}%',
                              style: TextStyle(
                                color: const Color(0xFF64748b),
                                fontSize: fontSize,
                              ),
                            ),
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < trendsData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                trendsData[value.toInt()].month,
                                style: TextStyle(
                                  color: const Color(0xFF64748b),
                                  fontSize: fontSize,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 100,
                  barGroups:
                      trendsData
                          .asMap()
                          .entries
                          .map(
                            (e) => BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.percentage,
                                  color: const Color(0xFF10b981),
                                  width: barWidth,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem:
                          (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                            '${rod.toY.toInt()}%',
                            TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Legend Item Widget
class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1e293b),
        ),
      ),
    ],
  );
}
