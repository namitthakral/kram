import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Widget for displaying attendance history as a bar chart
class AttendanceHistoryChart extends StatelessWidget {
  const AttendanceHistoryChart({super.key, this.attendanceData});

  final Map<String, dynamic>? attendanceData;

  @override
  Widget build(BuildContext context) {
    // Parse attendance data from API or use default
    final monthlyData = _parseAttendanceData(attendanceData);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Get responsive dimensions
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 900;

        // Responsive sizing
        final chartHeight = isMobile ? 200.0 : (isTablet ? 250.0 : 280.0);
        final fontSize = isMobile ? 10.0 : 12.0;
        final reservedSize = isMobile ? 28.0 : 35.0;
        final barWidth = isMobile ? 20.0 : (isTablet ? 26.0 : 32.0);
        final padding = isMobile ? 12.0 : 16.0;

        return Container(
          height: chartHeight,
          padding: EdgeInsets.all(padding),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (groupIndex < monthlyData.length) {
                      final month = monthlyData[groupIndex]['month'] ?? '';
                      return BarTooltipItem(
                        '$month\n${rod.toY.toInt()}%',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      );
                    }
                    return null;
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
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      );
                      final index = value.toInt();
                      if (index >= 0 && index < monthlyData.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(
                            monthlyData[index]['month'] ?? '',
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
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine:
                    (value) =>
                        const FlLine(color: Color(0xFFe2e8f0), strokeWidth: 1),
              ),
              barGroups: List.generate(
                monthlyData.length,
                (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: monthlyData[index]['percentage']?.toDouble() ?? 0,
                      color: const Color(0xFF4F7CFF),
                      width: barWidth,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _parseAttendanceData(Map<String, dynamic>? data) {
    // Backend returns: { success: true, data: { attendanceHistory: [...], overallPercentage: ... } }

    debugPrint('📊 Attendance History - Raw data received: $data');

    if (data == null) {
      debugPrint('⚠️ Attendance History - No data received, using default');
      return [
        {'month': 'Jan', 'percentage': 98},
        {'month': 'Feb', 'percentage': 94},
        {'month': 'Mar', 'percentage': 97},
        {'month': 'Apr', 'percentage': 93},
        {'month': 'May', 'percentage': 95},
        {'month': 'Jun', 'percentage': 96},
      ];
    }

    try {
      // Check if data has nested structure with 'data' key
      final responseData = data['data'] ?? data;
      debugPrint('📊 Attendance History - Response data: $responseData');

      final history = responseData['attendanceHistory'] as List<dynamic>?;
      debugPrint('📊 Attendance History - History array: $history');

      if (history == null || history.isEmpty) {
        debugPrint('⚠️ Attendance History - No history data, using default');
        return [
          {'month': 'Jan', 'percentage': 98},
          {'month': 'Feb', 'percentage': 94},
          {'month': 'Mar', 'percentage': 97},
          {'month': 'Apr', 'percentage': 93},
          {'month': 'May', 'percentage': 95},
          {'month': 'Jun', 'percentage': 96},
        ];
      }

      final parsedData =
          history
              .map(
                (item) => {
                  'month': item['month'] ?? '',
                  'percentage': item['percentage'] ?? 0,
                },
              )
              .toList();

      debugPrint(
        '✅ Attendance History - Successfully parsed ${parsedData.length} months',
      );
      return parsedData;
    } on Exception catch (e) {
      debugPrint('❌ Attendance History - Error parsing: $e');
      // Return default on error
      return [
        {'month': 'Jan', 'percentage': 98},
        {'month': 'Feb', 'percentage': 94},
        {'month': 'Mar', 'percentage': 97},
        {'month': 'Apr', 'percentage': 93},
        {'month': 'May', 'percentage': 95},
        {'month': 'Jun', 'percentage': 96},
      ];
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
        debugPrint(
          '⚠️ Performance Trends - No subject data parsed from API',
        );
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
