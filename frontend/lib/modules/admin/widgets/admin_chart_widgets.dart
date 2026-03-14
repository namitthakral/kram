import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/admin_dashboard_models.dart';

/// Widget for displaying school-wide attendance trends as a line chart
class AdminAttendanceTrendsChart extends StatelessWidget {
  const AdminAttendanceTrendsChart({super.key, this.trendsData});

  final List<AttendanceTrend>? trendsData;

  List<AttendanceTrend> _getDefaultData() => [
    AttendanceTrend(month: 'Jan', actualAttendance: 0, targetAttendance: 95),
    AttendanceTrend(month: 'Feb', actualAttendance: 0, targetAttendance: 95),
    AttendanceTrend(month: 'Mar', actualAttendance: 0, targetAttendance: 95),
    AttendanceTrend(month: 'Apr', actualAttendance: 0, targetAttendance: 95),
    AttendanceTrend(month: 'May', actualAttendance: 0, targetAttendance: 95),
    AttendanceTrend(month: 'Jun', actualAttendance: 0, targetAttendance: 95),
  ];

  @override
  Widget build(BuildContext context) {
    final data = trendsData ?? _getDefaultData();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            horizontalInterval: 5,
            verticalInterval: 1,
            getDrawingHorizontalLine:
                (value) => const FlLine(
                  color: Color(0xFFe2e8f0),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
            getDrawingVerticalLine:
                (value) => const FlLine(
                  color: Color(0xFFe2e8f0),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: Color(0xFF64748b),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  );
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(data[index].month, style: style),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: Color(0xFF64748b),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  );
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text('${value.toInt()}', style: style),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xFFe2e8f0)),
          ),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            // Actual attendance line
            LineChartBarData(
              spots: List.generate(
                data.length,
                (index) =>
                    FlSpot(index.toDouble(), data[index].actualAttendance),
              ),
              isCurved: true,
              color: const Color(0xFF10b981),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                getDotPainter:
                    (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 5,
                      color: const Color(0xFF10b981),
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
              ),
              belowBarData: BarAreaData(),
            ),
            // Target line
            LineChartBarData(
              spots: List.generate(
                data.length,
                (index) =>
                    FlSpot(index.toDouble(), data[index].targetAttendance),
              ),
              color: const Color(0xFFef4444),
              isStrokeCapRound: true,
              dashArray: [8, 4],
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems:
                  (List<LineBarSpot> touchedBarSpots) =>
                      touchedBarSpots.map((barSpot) {
                        final flSpot = barSpot;
                        final index = flSpot.x.toInt();
                        if (index >= 0 && index < data.length) {
                          final month = data[index].month;
                          final value = flSpot.y.toStringAsFixed(1);
                          final label =
                              barSpot.barIndex == 0 ? 'Actual' : 'Target';
                          return LineTooltipItem(
                            '$month\n$label: $value%',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return null;
                      }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget for displaying grade distribution as a bar chart
class AdminGradeDistributionChart extends StatelessWidget {
  const AdminGradeDistributionChart({super.key, this.distributionData});

  final List<GradeDistribution>? distributionData;

  List<GradeDistribution> _getDefaultData() => [
    GradeDistribution(grade: 'A+', count: 0),
    GradeDistribution(grade: 'A', count: 0),
    GradeDistribution(grade: 'B+', count: 0),
    GradeDistribution(grade: 'B', count: 0),
    GradeDistribution(grade: 'C', count: 0),
  ];

  @override
  Widget build(BuildContext context) {
    final data = distributionData ?? _getDefaultData();
    final maxY =
        data.isEmpty
            ? 100.0
            : (data.map((e) => e.count).reduce((a, b) => a > b ? a : b) * 1.2)
                .ceilToDouble();

    return Container(
      height: 300,
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
                final grade = data[groupIndex].grade;
                final count = rod.toY.toInt();
                return BarTooltipItem(
                  '$grade\nStudents: $count',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
                    fontSize: 14,
                  );
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(data[index].grade, style: style),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: maxY > 100 ? (maxY / 5).ceilToDouble() : 20,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: Color(0xFF64748b),
                    fontWeight: FontWeight.w500,
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
          barGroups: List.generate(data.length, (index) {
            final item = data[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: item.count > 0 ? item.count.toDouble() : 0.5,
                  color: const Color(0xFF3b82f6),
                  width: 40,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

/// Widget for displaying class performance overview
class AdminClassPerformanceList extends StatelessWidget {
  const AdminClassPerformanceList({super.key, this.classData});

  final List<ClassPerformance>? classData;

  @override
  Widget build(BuildContext context) {
    final data = classData ?? [];

    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No class data available',
            style: TextStyle(fontSize: 16, color: Color(0xFF64748b)),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final classItem = data[index];
        return _buildClassPerformanceRow(
          classItem.className,
          classItem.studentCount,
          classItem.avgGrade,
          classItem.attendanceRate,
        );
      },
    );
  }

  Widget _buildClassPerformanceRow(
    String className,
    int studentCount,
    double avgGrade,
    double attendanceRate,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            className,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1e293b),
            ),
          ),
        ),
        Expanded(
          child: Text(
            '$studentCount students',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '${avgGrade.toStringAsFixed(1)}% avg',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1e293b),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: avgGrade / 100,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFe2e8f0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF3b82f6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              Text(
                '${attendanceRate.toStringAsFixed(1)}% attendance',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1e293b),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: attendanceRate / 100,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFe2e8f0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF10b981),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Widget for displaying financial overview as area chart
class AdminFinancialOverviewChart extends StatelessWidget {
  const AdminFinancialOverviewChart({super.key, this.financialData});

  final List<FinancialOverview>? financialData;

  List<FinancialOverview> _getDefaultData() => [
    FinancialOverview(month: 'Jan', expenses: 0, feeCollection: 0, profit: 0),
    FinancialOverview(month: 'Feb', expenses: 0, feeCollection: 0, profit: 0),
    FinancialOverview(month: 'Mar', expenses: 0, feeCollection: 0, profit: 0),
    FinancialOverview(month: 'Apr', expenses: 0, feeCollection: 0, profit: 0),
    FinancialOverview(month: 'May', expenses: 0, feeCollection: 0, profit: 0),
    FinancialOverview(month: 'Jun', expenses: 0, feeCollection: 0, profit: 0),
  ];

  @override
  Widget build(BuildContext context) {
    final data = financialData ?? _getDefaultData();
    var maxY =
        data.isEmpty
            ? 300000.0
            : ([
                      ...data.map((e) => e.expenses),
                      ...data.map((e) => e.feeCollection),
                      ...data.map((e) => e.profit),
                    ].reduce((a, b) => a > b ? a : b) *
                    1.1)
                .ceilToDouble();

    // Ensure maxY is never 0 to avoid division by zero
    if (maxY == 0) {
      maxY = 300000.0;
    }

    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            horizontalInterval: maxY / 5,
            verticalInterval: 1,
            getDrawingHorizontalLine:
                (value) => const FlLine(
                  color: Color(0xFFe2e8f0),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
            getDrawingVerticalLine:
                (value) => const FlLine(
                  color: Color(0xFFe2e8f0),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: Color(0xFF64748b),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  );
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(data[index].month, style: style),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: maxY / 5,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: Color(0xFF64748b),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  );
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text('${(value / 1000).toInt()}k', style: style),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xFFe2e8f0)),
          ),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            // Expenses
            LineChartBarData(
              spots: List.generate(
                data.length,
                (index) => FlSpot(index.toDouble(), data[index].expenses),
              ),
              isCurved: true,
              color: const Color(0xFFef4444),
              barWidth: 0,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFef4444).withValues(alpha: 0.3),
              ),
            ),
            // Fee Collection
            LineChartBarData(
              spots: List.generate(
                data.length,
                (index) => FlSpot(index.toDouble(), data[index].feeCollection),
              ),
              isCurved: true,
              color: const Color(0xFF3b82f6),
              barWidth: 0,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF3b82f6).withValues(alpha: 0.3),
              ),
            ),
            // Profit
            LineChartBarData(
              spots: List.generate(
                data.length,
                (index) => FlSpot(index.toDouble(), data[index].profit),
              ),
              isCurved: true,
              color: const Color(0xFF10b981),
              barWidth: 0,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF10b981).withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying teacher performance table
class AdminTeacherPerformanceTable extends StatelessWidget {
  const AdminTeacherPerformanceTable({super.key, this.teacherData});

  final List<TeacherPerformance>? teacherData;

  @override
  Widget build(BuildContext context) {
    final data = teacherData ?? [];

    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No teacher data available',
            style: TextStyle(fontSize: 16, color: Color(0xFF64748b)),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFf1f5f9)),
        columns: const [
          DataColumn(
            label: Text(
              'Teacher',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Subject',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Students',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Avg Grade',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Rating',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows:
            data
                .map(
                  (teacher) => DataRow(
                    cells: [
                      DataCell(Text(teacher.teacherName)),
                      DataCell(Text(teacher.subject)),
                      DataCell(Text('${teacher.students}')),
                      DataCell(Text('${teacher.avgGrade.toStringAsFixed(1)}%')),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFf59e0b),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              teacher.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
      ),
    );
  }
}
