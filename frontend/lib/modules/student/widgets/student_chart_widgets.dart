import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Widget for displaying attendance history as a pie chart
class AttendanceHistoryChart extends StatefulWidget {
  const AttendanceHistoryChart({super.key, this.attendanceData});

  final Map<String, dynamic>? attendanceData;

  @override
  State<AttendanceHistoryChart> createState() => _AttendanceHistoryChartState();
}

class _AttendanceHistoryChartState extends State<AttendanceHistoryChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Parse attendance data from API or use default
    final data = _parseAttendanceData(widget.attendanceData);
    final hasData = data.any((element) => element['value'] > 0);

    return SizedBox(
      height: 300,
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
                      'No attendance data available',
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
                        centerSpaceRadius: 20,
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
                                item['label']!,
                                '${item['percentage'].toInt()}%',
                                _parseColor(item['color']!),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) => Row(
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
        '$label - $value',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1e293b),
        ),
      ),
    ],
  );

  List<PieChartSectionData> _showingSections(List<Map<String, dynamic>> data) =>
      List.generate(data.length, (i) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 20.0 : 16.0;
        final radius = isTouched ? 110.0 : 100.0;
        const shadows = [Shadow(blurRadius: 2)];
        final item = data[i];

        return PieChartSectionData(
          color: _parseColor(item['color']!),
          value: item['value'] > 0 ? item['value'].toDouble() : 0.1,
          title: '${item['percentage'].toInt()}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadows,
          ),
          badgeWidget: _AttendanceBadge(
            label: item['label']!,
            size: isTouched ? 55.0 : 40.0,
            borderColor: _parseColor(item['color']!),
          ),
          badgePositionPercentageOffset: .98,
        );
      });

  Color _parseColor(String colorString) {
    final hexColor = colorString.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  List<Map<String, dynamic>> _parseAttendanceData(Map<String, dynamic>? data) {
    // Backend returns: { success: true, data: { attendanceHistory: [...], overallPercentage: ..., summary: { present: X, absent: Y, late: Z } } }

    debugPrint('📊 Attendance History - Raw data received: $data');

    if (data == null) {
      debugPrint('⚠️ Attendance History - No data received, using default');
      return [
        {
          'label': 'Present',
          'value': 90,
          'percentage': 90.0,
          'color': '#10b981',
        },
        {'label': 'Absent', 'value': 5, 'percentage': 5.0, 'color': '#ef4444'},
        {'label': 'Late', 'value': 5, 'percentage': 5.0, 'color': '#f59e0b'},
      ];
    }

    try {
      // Check if data has nested structure with 'data' key
      final responseData = data['data'] ?? data;
      debugPrint('📊 Attendance History - Response data: $responseData');

      // Try to get summary data
      final summary = responseData['summary'] as Map<String, dynamic>?;

      if (summary != null) {
        final present = (summary['present'] ?? 0).toDouble();
        final absent = (summary['absent'] ?? 0).toDouble();
        final late = (summary['late'] ?? 0).toDouble();
        final total = present + absent + late;

        if (total > 0) {
          debugPrint('✅ Attendance History - Using summary data');
          return [
            {
              'label': 'Present',
              'value': present,
              'percentage': (present / total) * 100,
              'color': '#10b981',
            },
            {
              'label': 'Absent',
              'value': absent,
              'percentage': (absent / total) * 100,
              'color': '#ef4444',
            },
            if (late > 0)
              {
                'label': 'Late',
                'value': late,
                'percentage': (late / total) * 100,
                'color': '#f59e0b',
              },
          ];
        }
      }

      // Fallback: Calculate from attendance history
      final history = responseData['attendanceHistory'] as List<dynamic>?;
      if (history != null && history.isNotEmpty) {
        debugPrint('📊 Attendance History - Calculating from history');

        // Assuming total days per month is 30 for calculation
        final totalMonths = history.length;
        final avgPercentage =
            history.fold<double>(
              0.0,
              (sum, item) =>
                  sum + ((item['percentage'] ?? 0) as num).toDouble(),
            ) /
            totalMonths;

        final presentDays = (avgPercentage * totalMonths * 30 / 100).round();
        final totalDays = totalMonths * 30;
        final absentDays = totalDays - presentDays;

        return [
          {
            'label': 'Present',
            'value': presentDays,
            'percentage': avgPercentage,
            'color': '#10b981',
          },
          {
            'label': 'Absent',
            'value': absentDays,
            'percentage': 100 - avgPercentage,
            'color': '#ef4444',
          },
        ];
      }

      debugPrint('⚠️ Attendance History - No valid data, using default');
      return [
        {
          'label': 'Present',
          'value': 90,
          'percentage': 90.0,
          'color': '#10b981',
        },
        {'label': 'Absent', 'value': 5, 'percentage': 5.0, 'color': '#ef4444'},
        {'label': 'Late', 'value': 5, 'percentage': 5.0, 'color': '#f59e0b'},
      ];
    } on Exception catch (e) {
      debugPrint('❌ Attendance History - Error parsing: $e');
      return [
        {
          'label': 'Present',
          'value': 90,
          'percentage': 90.0,
          'color': '#10b981',
        },
        {'label': 'Absent', 'value': 5, 'percentage': 5.0, 'color': '#ef4444'},
        {'label': 'Late', 'value': 5, 'percentage': 5.0, 'color': '#f59e0b'},
      ];
    }
  }
}

class _AttendanceBadge extends StatelessWidget {
  const _AttendanceBadge({
    required this.label,
    required this.size,
    required this.borderColor,
  });

  final String label;
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
          _getShortLabel(label),
          style: TextStyle(
            fontSize: size * 0.3,
            fontWeight: FontWeight.bold,
            color: borderColor,
          ),
        ),
      ),
    ),
  );

  String _getShortLabel(String label) {
    // Convert label to short form for badge
    switch (label.toLowerCase()) {
      case 'present':
        return 'P';
      case 'absent':
        return 'A';
      case 'late':
        return 'L';
      default:
        return label.substring(0, 1).toUpperCase();
    }
  }
}

/// Widget for displaying performance trends as a line chart
class PerformanceTrendsChart extends StatelessWidget {
  const PerformanceTrendsChart({super.key, this.trendsData});

  final Map<String, dynamic>? trendsData;

  @override
  Widget build(BuildContext context) {
    // Parse trends data from API or use default
    final parsedData = _parseTrendsData(trendsData);
    final months = parsedData['months'] as List<String>;
    final subjects = parsedData['subjects'] as List<Map<String, dynamic>>;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Get responsive dimensions
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 900;

        // Responsive sizing
        final chartHeight = isMobile ? 220.0 : (isTablet ? 280.0 : 320.0);
        final fontSize = isMobile ? 10.0 : 12.0;
        final reservedSize = isMobile ? 28.0 : 35.0;
        final dotRadius = isMobile ? 3.0 : 4.0;
        final lineWidth = isMobile ? 2.5 : 3.0;
        final padding = isMobile ? 12.0 : 16.0;

        return Container(
          height: chartHeight,
          padding: EdgeInsets.all(padding),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine:
                    (value) =>
                        const FlLine(color: Color(0xFFe2e8f0), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final style = TextStyle(
                        color: const Color(0xFF64748b),
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      );
                      final index = value.toInt();
                      if (index >= 0 && index < months.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(months[index], style: style),
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
                    interval: 25,
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
              minX: 0,
              maxX: (months.length - 1).toDouble(),
              minY: 50,
              maxY: 100,
              lineBarsData:
                  subjects.map((subject) {
                    final spots = subject['data'] as List<FlSpot>;
                    final color = _parseColor(subject['color'] ?? '#4F7CFF');

                    return LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: lineWidth,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        getDotPainter:
                            (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: dotRadius,
                                  color: color,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                      ),
                      belowBarData: BarAreaData(),
                    );
                  }).toList(),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems:
                      (touchedSpots) =>
                          touchedSpots
                              .map(
                                (LineBarSpot touchedSpot) => LineTooltipItem(
                                  '${touchedSpot.y.toInt()}%',
                                  TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSize,
                                  ),
                                ),
                              )
                              .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _parseTrendsData(Map<String, dynamic>? data) {
    // Backend returns: { success: true, data: { trends: [...], period: {...} } }
    // trends structure: [{ subject: "Math", subjectCode: "MTH101", dataPoints: [{month: "Jan", score: 90}] }]

    debugPrint('📊 Performance Trends - Raw data received: $data');

    if (data == null) {
      debugPrint('⚠️ Performance Trends - No data received from API');
      return _getEmptyTrendsData();
    }

    try {
      // Check if data has nested structure with 'data' key
      final responseData = data['data'] ?? data;
      debugPrint('📊 Performance Trends - Response data: $responseData');

      final trends = responseData['trends'] as List<dynamic>?;
      debugPrint('📊 Performance Trends - Trends array: $trends');

      if (trends == null || trends.isEmpty) {
        debugPrint(
          '⚠️ Performance Trends - No trends data available from backend',
        );
        return _getEmptyTrendsData();
      }

      final months = <String>[];
      final subjectsMap = <String, Map<String, dynamic>>{};

      // Backend format: [{ subject: "Math", dataPoints: [{month: "Jan", score: 90}] }]
      for (final trendItem in trends) {
        final subjectName = trendItem['subject'] ?? '';
        final dataPoints = trendItem['dataPoints'] as List<dynamic>?;

        if (dataPoints == null || dataPoints.isEmpty) {
          continue;
        }

        final spots = <FlSpot>[];

        for (final point in dataPoints) {
          final month = point['month'] ?? '';
          final score = (point['score'] ?? 0).toDouble();

          // Add month if not already in list
          if (!months.contains(month)) {
            months.add(month);
          }

          // Add data point
          final monthIndex = months.indexOf(month).toDouble();
          spots.add(FlSpot(monthIndex, score));
        }

        // Generate a color for this subject if not specified
        final color = _getSubjectColor(subjectName);

        subjectsMap[subjectName] = {
          'name': subjectName,
          'color': color,
          'data': spots,
        };
      }

      if (subjectsMap.isEmpty) {
        debugPrint('⚠️ Performance Trends - No subject data parsed from API');
        return _getEmptyTrendsData();
      }

      debugPrint(
        '✅ Performance Trends - Successfully parsed ${subjectsMap.length} subjects with ${months.length} months',
      );

      return {'months': months, 'subjects': subjectsMap.values.toList()};
    } on Exception catch (e) {
      debugPrint('❌ Performance Trends - Error parsing: $e');
      return _getEmptyTrendsData();
    }
  }

  /// Returns empty data structure when no real data is available
  /// This will show minimal chart with a message about no data
  Map<String, dynamic> _getEmptyTrendsData() => {
    'months': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    'subjects': <Map<String, dynamic>>[],
  };

  String _getSubjectColor(String subjectName) {
    final colors = {
      'mathematics': '#4F7CFF',
      'math': '#4F7CFF',
      'physics': '#10b981',
      'chemistry': '#8B5CF6',
      'english': '#f59e0b',
      'history': '#ef4444',
      'biology': '#06b6d4',
      'computer': '#8b5cf6',
      'science': '#10b981',
    };

    final key = subjectName.toLowerCase();
    for (final entry in colors.entries) {
      if (key.contains(entry.key)) {
        return entry.value;
      }
    }

    return '#4F7CFF'; // Default color
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } on Exception catch (_) {
      return const Color(0xFF4F7CFF); // Default blue
    }
  }
}
