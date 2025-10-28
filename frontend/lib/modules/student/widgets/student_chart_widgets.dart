import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Widget for displaying attendance history as a bar chart
class AttendanceHistoryChart extends StatelessWidget {
  const AttendanceHistoryChart({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                  return BarTooltipItem(
                    '${months[group.x]}\nAttendance % : ${rod.toY.toInt()}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
                    const style = TextStyle(
                      color: Color(0xFF64748b),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    );
                    Widget text;
                    switch (value.toInt()) {
                      case 0:
                        text = const Text('Jan', style: style);
                        break;
                      case 1:
                        text = const Text('Feb', style: style);
                        break;
                      case 2:
                        text = const Text('Mar', style: style);
                        break;
                      case 3:
                        text = const Text('Apr', style: style);
                        break;
                      case 4:
                        text = const Text('May', style: style);
                        break;
                      case 5:
                        text = const Text('Jun', style: style);
                        break;
                      default:
                        text = const Text('', style: style);
                        break;
                    }
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4,
                      child: text,
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 25,
                  getTitlesWidget: (value, meta) {
                    const style = TextStyle(
                      color: Color(0xFF64748b),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
              horizontalInterval: 25,
              getDrawingHorizontalLine: (value) => const FlLine(
                color: Color(0xFFe2e8f0),
                strokeWidth: 1,
              ),
            ),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: 98,
                    color: const Color(0xFF4F7CFF),
                    width: 32,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: 94,
                    color: const Color(0xFF4F7CFF),
                    width: 32,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 2,
                barRods: [
                  BarChartRodData(
                    toY: 97,
                    color: const Color(0xFF4F7CFF),
                    width: 32,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 3,
                barRods: [
                  BarChartRodData(
                    toY: 93,
                    color: const Color(0xFF4F7CFF),
                    width: 32,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 4,
                barRods: [
                  BarChartRodData(
                    toY: 95,
                    color: const Color(0xFF4F7CFF),
                    width: 32,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 5,
                barRods: [
                  BarChartRodData(
                    toY: 96,
                    color: const Color(0xFF4F7CFF),
                    width: 32,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

/// Widget for displaying performance trends as a line chart
class PerformanceTrendsChart extends StatelessWidget {
  const PerformanceTrendsChart({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (value) => const FlLine(
                color: Color(0xFFe2e8f0),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    const style = TextStyle(
                      color: Color(0xFF64748b),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    );
                    Widget text;
                    switch (value.toInt()) {
                      case 0:
                        text = const Text('Jan', style: style);
                        break;
                      case 1:
                        text = const Text('Feb', style: style);
                        break;
                      case 2:
                        text = const Text('Mar', style: style);
                        break;
                      case 3:
                        text = const Text('Apr', style: style);
                        break;
                      case 4:
                        text = const Text('May', style: style);
                        break;
                      case 5:
                        text = const Text('Jun', style: style);
                        break;
                      default:
                        text = const Text('', style: style);
                        break;
                    }
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 8,
                      child: text,
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 25,
                  getTitlesWidget: (value, meta) {
                    const style = TextStyle(
                      color: Color(0xFF64748b),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    );
                    return Text(value.toInt().toString(), style: style);
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              border: Border.all(color: const Color(0xFFe2e8f0)),
            ),
            minX: 0,
            maxX: 5,
            minY: 50,
            maxY: 100,
            lineBarsData: [
              // Chemistry
              LineChartBarData(
                spots: const [
                  FlSpot(0, 85),
                  FlSpot(1, 87),
                  FlSpot(2, 86),
                  FlSpot(3, 88),
                  FlSpot(4, 87),
                  FlSpot(5, 89),
                ],
                isCurved: true,
                color: const Color(0xFF8B5CF6),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFF8B5CF6),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(),
              ),
              // English
              LineChartBarData(
                spots: const [
                  FlSpot(0, 92),
                  FlSpot(1, 93),
                  FlSpot(2, 94),
                  FlSpot(3, 94),
                  FlSpot(4, 95),
                  FlSpot(5, 95),
                ],
                isCurved: true,
                color: const Color(0xFFf59e0b),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFFf59e0b),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(),
              ),
              // History
              LineChartBarData(
                spots: const [
                  FlSpot(0, 80),
                  FlSpot(1, 82),
                  FlSpot(2, 81),
                  FlSpot(3, 83),
                  FlSpot(4, 83),
                  FlSpot(5, 84),
                ],
                isCurved: true,
                color: const Color(0xFFef4444),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFFef4444),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(),
              ),
              // Mathematics
              LineChartBarData(
                spots: const [
                  FlSpot(0, 90),
                  FlSpot(1, 90),
                  FlSpot(2, 91),
                  FlSpot(3, 90),
                  FlSpot(4, 91),
                  FlSpot(5, 92),
                ],
                isCurved: true,
                color: const Color(0xFF4F7CFF),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFF4F7CFF),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(),
              ),
              // Physics
              LineChartBarData(
                spots: const [
                  FlSpot(0, 88),
                  FlSpot(1, 88),
                  FlSpot(2, 89),
                  FlSpot(3, 88),
                  FlSpot(4, 89),
                  FlSpot(5, 89),
                ],
                isCurved: true,
                color: const Color(0xFF10b981),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 4,
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
                getTooltipItems: (touchedSpots) => touchedSpots.map((LineBarSpot touchedSpot) {
                    const textStyle = TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    );
                    return LineTooltipItem(
                      '${touchedSpot.y.toInt()}%',
                      textStyle,
                    );
                  }).toList(),
              ),
            ),
          ),
        ),
      );
}
