import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Widget for displaying attendance trends as a stacked bar chart
class AttendanceTrendsChart extends StatelessWidget {
  const AttendanceTrendsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 28,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
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
                      text = const Text('Mon', style: style);
                      break;
                    case 1:
                      text = const Text('Tue', style: style);
                      break;
                    case 2:
                      text = const Text('Wed', style: style);
                      break;
                    case 3:
                      text = const Text('Thu', style: style);
                      break;
                    case 4:
                      text = const Text('Fri', style: style);
                      break;
                    default:
                      text = const Text('', style: style);
                      break;
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 16,
                    child: text,
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 7,
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
            show: true,
            border: Border.all(color: const Color(0xFFe2e8f0), width: 1),
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: 25,
                  color: const Color(0xFF10b981),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: 3,
                  fromY: 0,
                  color: const Color(0xFFef4444),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: 24,
                  color: const Color(0xFF10b981),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: 4,
                  fromY: 0,
                  color: const Color(0xFFef4444),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: 26,
                  color: const Color(0xFF10b981),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: 2,
                  fromY: 0,
                  color: const Color(0xFFef4444),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: 25,
                  color: const Color(0xFF10b981),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: 3,
                  fromY: 0,
                  color: const Color(0xFFef4444),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(
                  toY: 22,
                  color: const Color(0xFF10b981),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: 6,
                  fromY: 0,
                  color: const Color(0xFFef4444),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying subject performance as horizontal progress bars
class SubjectPerformanceChart extends StatelessWidget {
  const SubjectPerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSubjectProgress('Mathematics', 85),
          const SizedBox(height: 16),
          _buildSubjectProgress('Science', 78),
          const SizedBox(height: 16),
          _buildSubjectProgress('English', 82),
          const SizedBox(height: 16),
          _buildSubjectProgress('History', 76),
        ],
      ),
    );
  }

  Widget _buildSubjectProgress(String subject, int percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subject,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1e293b),
              ),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F7CFF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 10,
            backgroundColor: const Color(0xFFe2e8f0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F7CFF)),
          ),
        ),
      ],
    );
  }
}

/// Widget for displaying grade distribution as a donut chart
class GradeDistributionChart extends StatelessWidget {
  const GradeDistributionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(enabled: true),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFFf59e0b),
                    value: 30,
                    title: 'B+',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF4F7CFF),
                    value: 25,
                    title: 'A',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFef4444),
                    value: 20,
                    title: 'B',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF10b981),
                    value: 15,
                    title: 'A+',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF64748b),
                    value: 10,
                    title: 'C',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('A+', 15, const Color(0xFF10b981)),
                const SizedBox(height: 8),
                _buildLegendItem('A', 25, const Color(0xFF4F7CFF)),
                const SizedBox(height: 8),
                _buildLegendItem('B+', 30, const Color(0xFFf59e0b)),
                const SizedBox(height: 8),
                _buildLegendItem('B', 20, const Color(0xFFef4444)),
                const SizedBox(height: 8),
                _buildLegendItem('C', 10, const Color(0xFF64748b)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String grade, int percentage, Color color) {
    return Row(
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
          '$grade $percentage%',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1e293b),
          ),
        ),
      ],
    );
  }
}
