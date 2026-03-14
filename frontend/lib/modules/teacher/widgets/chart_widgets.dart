import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/dashboard_stats.dart';

/// Widget for displaying attendance trends as a stacked bar chart
class AttendanceTrendsChart extends StatelessWidget {
  const AttendanceTrendsChart({super.key, this.trendsData});

  final AttendanceTrendsResponse? trendsData;

  List<AttendanceData> _getDefaultData() => const [
    AttendanceData(day: 'Mon', present: 0, absent: 0),
    AttendanceData(day: 'Tue', present: 0, absent: 0),
    AttendanceData(day: 'Wed', present: 0, absent: 0),
    AttendanceData(day: 'Thu', present: 0, absent: 0),
    AttendanceData(day: 'Fri', present: 0, absent: 0),
  ];

  double _calculateMaxY(List<AttendanceData> data) {
    if (data.isEmpty) {
      return 10;
    }
    final maxValue = data.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) {
      return 10;
    }
    return (maxValue * 1.2).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final data =
        trendsData != null
            ? trendsData!.weeklyOverview.dailyAttendance
                .map(
                  (e) => AttendanceData(
                    day: e.day,
                    present: e.present,
                    absent: e.absent,
                  ),
                )
                .toList()
            : _getDefaultData();
    final maxY = _calculateMaxY(data);

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final day = data[groupIndex].day;
                final present = data[groupIndex].present;
                final absent = data[groupIndex].absent;
                final total = data[groupIndex].total;
                return BarTooltipItem(
                  '$day\nPresent: $present\nAbsent: $absent\nTotal: $total',
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
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4,
                      child: Text(data[index].day, style: style),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY > 10 ? (maxY / 5).ceilToDouble() : 2,
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
            border: Border.all(color: const Color(0xFFe2e8f0)),
          ),
          barGroups: _buildBarGroups(data),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<AttendanceData> data) =>
      List.generate(data.length, (index) {
        final item = data[index];
        final presentValue = item.present.toDouble();
        final absentValue = item.absent.toDouble();
        final totalValue = presentValue + absentValue;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: totalValue > 0 ? totalValue : 0.5,
              width: 40,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              rodStackItems:
                  totalValue > 0
                      ? [
                        BarChartRodStackItem(
                          0,
                          presentValue,
                          const Color(0xFF10b981),
                        ),
                        BarChartRodStackItem(
                          presentValue,
                          totalValue,
                          const Color(0xFFef4444),
                        ),
                      ]
                      : null,
              color: totalValue == 0 ? const Color(0xFFe2e8f0) : null,
            ),
          ],
        );
      });
}

class SubjectPerformanceChart extends StatelessWidget {
  const SubjectPerformanceChart({super.key, this.performanceData});

  final SubjectPerformanceResponse? performanceData;

  List<SubjectPerformance> _getDefaultData() => const [
    SubjectPerformance(subject: 'Mathematics', percentage: 0),
    SubjectPerformance(subject: 'Science', percentage: 0),
    SubjectPerformance(subject: 'English', percentage: 0),
    SubjectPerformance(subject: 'History', percentage: 0),
  ];

  @override
  Widget build(BuildContext context) {
    final data =
        performanceData != null
            ? performanceData!.subjects
                .map(
                  (e) => SubjectPerformance(
                    subject: e.name,
                    percentage: e.averageScore,
                  ),
                )
                .toList()
            : _getDefaultData();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children:
            data
                .map(
                  (subject) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildSubjectProgress(
                      subject.subject,
                      subject.percentage,
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildSubjectProgress(String subject, double percentage) => Column(
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
            '${percentage.toInt()}%',
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

class GradeDistributionChart extends StatefulWidget {
  const GradeDistributionChart({super.key, this.distributionData});

  final GradeDistributionResponse? distributionData;

  @override
  State<GradeDistributionChart> createState() => _GradeDistributionChartState();
}

class _GradeDistributionChartState extends State<GradeDistributionChart> {
  int touchedIndex = -1;

  List<GradeDistribution> _getDefaultData() => const [
    GradeDistribution(grade: 'A+', percentage: 0, color: '#10b981'),
    GradeDistribution(grade: 'A', percentage: 0, color: '#4F7CFF'),
    GradeDistribution(grade: 'B+', percentage: 0, color: '#f59e0b'),
    GradeDistribution(grade: 'B', percentage: 0, color: '#ef4444'),
    GradeDistribution(grade: 'C', percentage: 0, color: '#64748b'),
  ];

  Color _parseColor(String colorString) {
    final hexColor = colorString.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  List<GradeDistribution> _getChartData() {
    if (widget.distributionData == null) {
      return _getDefaultData();
    }

    final gradeBreakdown =
        widget.distributionData!.overallDistribution.percentageBreakdown;
    final result = <GradeDistribution>[];
    final gradeColors = {
      'A+': '#10b981',
      'A': '#4F7CFF',
      'A-': '#22c55e',
      'B+': '#f59e0b',
      'B': '#f97316',
      'B-': '#fb923c',
      'C+': '#ef4444',
      'C': '#dc2626',
      'D': '#64748b',
      'F': '#94a3b8',
    };

    gradeBreakdown.forEach((grade, percentage) {
      result.add(
        GradeDistribution(
          grade: grade,
          percentage: percentage.toDouble(),
          color: gradeColors[grade] ?? '#64748b',
        ),
      );
    });

    return result.isNotEmpty ? result : _getDefaultData();
  }

  @override
  Widget build(BuildContext context) {
    final data = _getChartData();
    final hasData = data.any((element) => element.percentage > 0);

    return SizedBox(
      height: 320,
      child:
          !hasData
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No grade data available',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (
                            FlTouchEvent event,
                            pieTouchResponse,
                          ) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex =
                                  pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 0,
                        centerSpaceRadius: 30,
                        sections: _showingSections(data),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children:
                        data
                            .map(
                              (item) => _buildLegendItem(
                                item.grade,
                                '${item.percentage.toInt()}%',
                                _parseColor(item.color),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
    );
  }

  Widget _buildLegendItem(String grade, String value, Color color) => Row(
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
      const SizedBox(width: 4),
      Text(
        '$grade - $value',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1e293b),
        ),
      ),
    ],
  );

  List<PieChartSectionData> _showingSections(List<GradeDistribution> data) =>
      List.generate(data.length, (i) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 20.0 : 16.0;
        final radius = isTouched ? 110.0 : 100.0;
        const shadows = [Shadow(blurRadius: 2)];
        final item = data[i];

        return PieChartSectionData(
          color: _parseColor(item.color),
          value: item.percentage > 0 ? item.percentage : 0.1,
          title: '${item.percentage.toInt()}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadows,
          ),
          badgeWidget: _GradeBadge(
            grade: item.grade,
            size: isTouched ? 55.0 : 40.0,
            borderColor: _parseColor(item.color),
          ),
          badgePositionPercentageOffset: .98,
        );
      });
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({
    required this.grade,
    required this.size,
    required this.borderColor,
  });

  final String grade;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: PieChart.defaultDuration,
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: borderColor, width: 2),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          offset: const Offset(3, 3),
          blurRadius: 3,
        ),
      ],
    ),
    padding: EdgeInsets.all(size * .15),
    child: Center(
      child: FittedBox(
        child: Text(
          grade,
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: borderColor,
          ),
        ),
      ),
    ),
  );
}
