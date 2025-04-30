import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

enum ChartViewMode {
  line,
  area,
  bar,
}

class HistoricalChart extends StatefulWidget {
  final Map<String, dynamic> chartData;
  final String fromCurrency;
  final String toCurrency;

  const HistoricalChart({
    super.key,
    required this.chartData,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  State<HistoricalChart> createState() => _HistoricalChartState();
}

class _HistoricalChartState extends State<HistoricalChart> {
  ChartViewMode _viewMode = ChartViewMode.line;
  bool _showHighLowPoints = true;
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.chartData.isEmpty || !widget.chartData.containsKey('rates')) {
      return const Center(
        child: Text('No chart data available'),
      );
    }

    try {
      // Process chart data
      final Map<String, dynamic> rates = widget.chartData['rates'];
      final List<FlSpot> spots = [];
      final List<String> dates = [];

      // Sort dates to ensure chronological order
      final sortedDates = rates.keys.toList()..sort();

      // Create data points for the chart
      for (int i = 0; i < sortedDates.length; i++) {
        final date = sortedDates[i];
        if (rates[date] != null && rates[date][widget.toCurrency] != null) {
          final rate = rates[date][widget.toCurrency].toDouble();
          spots.add(FlSpot(i.toDouble(), rate));
          dates.add(date);
        }
      }

      if (spots.isEmpty) {
        return const Center(
          child: Text('No valid data points for the selected currencies'),
        );
      }

      // Find min and max values for better chart scaling
      double minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) * 0.95;
      double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.05;

      // Find highest and lowest points
      final highestPoint = spots.reduce((a, b) => a.y > b.y ? a : b);
      final lowestPoint = spots.reduce((a, b) => a.y < b.y ? a : b);
      
      // Calculate statistics
      final firstRate = spots.first.y;
      final lastRate = spots.last.y;
      final changeAmount = lastRate - firstRate;
      final changePercent = (changeAmount / firstRate) * 100;
      final isPositiveChange = changeAmount >= 0;
      
      // Format currency for display
      final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 4);

      // Adjust layout based on screen size
      final screenSize = MediaQuery.of(context).size;
      final isSmallScreen = screenSize.width < 360;
      final chartHeight = (screenSize.height * 0.28).clamp(180.0, 300.0);
      
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chart header with statistics
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exchange Rate: ${widget.fromCurrency} to ${widget.toCurrency}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildStatCard(
                                'Current',
                                currencyFormat.format(lastRate),
                                widget.toCurrency,
                                Icons.currency_exchange,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'Change',
                                '${changeAmount >= 0 ? '+' : ''}${currencyFormat.format(changeAmount)}',
                                '${changePercent.toStringAsFixed(2)}%',
                                isPositiveChange ? Icons.trending_up : Icons.trending_down,
                                color: isPositiveChange ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'High',
                                currencyFormat.format(highestPoint.y),
                                widget.toCurrency,
                                Icons.arrow_upward,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'Low',
                                currencyFormat.format(lowestPoint.y),
                                widget.toCurrency,
                                Icons.arrow_downward,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Chart view mode selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // View mode toggle
                    SegmentedButton<ChartViewMode>(
                      segments: const [
                        ButtonSegment(
                          value: ChartViewMode.line,
                          icon: Icon(Icons.show_chart),
                          label: Text('Line'),
                        ),
                        ButtonSegment(
                          value: ChartViewMode.area,
                          icon: Icon(Icons.area_chart),
                          label: Text('Area'),
                        ),
                        ButtonSegment(
                          value: ChartViewMode.bar,
                          icon: Icon(Icons.bar_chart),
                          label: Text('Bar'),
                        ),
                      ],
                      selected: {_viewMode},
                      onSelectionChanged: (Set<ChartViewMode> newSelection) {
                        setState(() {
                          _viewMode = newSelection.first;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // High/low points toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Show High/Low'),
                        Switch(
                          value: _showHighLowPoints,
                          onChanged: (value) {
                            setState(() {
                              _showHighLowPoints = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // The chart
                SizedBox(
                  height: chartHeight,
                  child: _viewMode == ChartViewMode.bar 
                      ? _buildBarChart(context, spots, dates, minY, maxY, highestPoint, lowestPoint)
                      : _buildLineChart(context, spots, dates, minY, maxY, highestPoint, lowestPoint),
                ),
                
                // Date range indicator
                if (dates.isNotEmpty) Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat(isSmallScreen ? 'MM/dd' : 'MMM dd, yyyy').format(DateTime.parse(dates.first)),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        DateFormat(isSmallScreen ? 'MM/dd' : 'MMM dd, yyyy').format(DateTime.parse(dates.last)),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      );
    } catch (e) {
      return Center(
        child: Text('Error rendering chart: ${e.toString()}'),
      );
    }
  }

  Widget _buildStatCard(String label, String value, String subtitle, IconData icon, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLineChart(
    BuildContext context, 
    List<FlSpot> spots, 
    List<String> dates, 
    double minY, 
    double maxY,
    FlSpot highestPoint,
    FlSpot lowestPoint,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: (maxY - minY) / 5,
          verticalInterval: spots.length > 30 ? 5 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: _buildTitlesData(context, spots, dates),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineTouchData: _buildTouchData(context, spots, dates),
        extraLinesData: _showHighLowPoints ? ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: highestPoint.y,
              color: Colors.green.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 8, bottom: 2),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                labelResolver: (line) => 'High: ${line.y.toStringAsFixed(4)}',
              ),
            ),
            HorizontalLine(
              y: lowestPoint.y,
              color: Colors.red.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.only(right: 8, top: 2),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                labelResolver: (line) => 'Low: ${line.y.toStringAsFixed(4)}',
              ),
            ),
          ],
        ) : null,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: _touchedIndex != -1,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: index == _touchedIndex ? 6 : 4,
                  color: index == _touchedIndex 
                      ? primaryColor 
                      : (spot.y == highestPoint.y && _showHighLowPoints)
                          ? Colors.green
                          : (spot.y == lowestPoint.y && _showHighLowPoints)
                              ? Colors.red
                              : primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: _viewMode == ChartViewMode.area,
              color: primaryColor.withOpacity(0.2),
              gradient: _viewMode == ChartViewMode.area ? LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.4),
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    BuildContext context, 
    List<FlSpot> spots, 
    List<String> dates, 
    double minY, 
    double maxY,
    FlSpot highestPoint,
    FlSpot lowestPoint,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = spots.length > 30 
        ? (screenWidth / (spots.length * 2)).clamp(2.0, 8.0) 
        : (screenWidth / (spots.length * 3)).clamp(6.0, 16.0);
    
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: _buildTitlesData(context, spots, dates),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minY: minY,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Theme.of(context).colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final index = group.x.toInt();
              if (index >= 0 && index < dates.length) {
                final date = dates[index];
                final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(date));
                return BarTooltipItem(
                  '$formattedDate\n${rod.toY.toStringAsFixed(4)} ${widget.toCurrency}',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
              return null;
            },
          ),
          touchCallback: (FlTouchEvent event, BarTouchResponse? touchResponse) {
            setState(() {
              if (event is FlTapUpEvent || event is FlLongPressEnd) {
                _touchedIndex = -1;
              } else if (touchResponse?.spot != null) {
                _touchedIndex = touchResponse!.spot!.touchedBarGroupIndex;
              }
            });
          },
        ),
        barGroups: spots.asMap().entries.map((entry) {
          final index = entry.key;
          final spot = entry.value;
          
          Color barColor = Theme.of(context).colorScheme.primary;
          if (_showHighLowPoints) {
            if (spot.y == highestPoint.y) {
              barColor = Colors.green;
            } else if (spot.y == lowestPoint.y) {
              barColor = Colors.red;
            }
          }
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: spot.y,
                color: barColor,
                width: barWidth,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: Colors.grey.shade200,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  FlTitlesData _buildTitlesData(BuildContext context, List<FlSpot> spots, List<String> dates) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            // Show only some dates to avoid overcrowding
            final interval = spots.length > 30 ? spots.length ~/ 5 : 
                             isSmallScreen ? 10 : 5;
            if (value.toInt() % interval == 0 && value.toInt() < dates.length) {
              final date = dates[value.toInt()];
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat('MM-dd').format(DateTime.parse(date)),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 8 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toStringAsFixed(isSmallScreen ? 1 : 2),
              style: TextStyle(
                fontSize: isSmallScreen ? 8 : 10,
                fontWeight: FontWeight.bold,
              ),
            );
          },
          reservedSize: isSmallScreen ? 30 : 40,
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  LineTouchData _buildTouchData(BuildContext context, List<FlSpot> spots, List<String> dates) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Theme.of(context).colorScheme.surface,
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.all(8),
        tooltipMargin: 8,
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          return touchedBarSpots.map((barSpot) {
            final index = barSpot.x.toInt();
            if (index >= 0 && index < dates.length) {
              final date = dates[index];
              final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(date));
              return LineTooltipItem(
                '$formattedDate\n${barSpot.y.toStringAsFixed(4)} ${widget.toCurrency}',
                TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return null;
          }).toList();
        },
      ),
      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
        setState(() {
          if (event is FlTapUpEvent || event is FlLongPressEnd) {
            _touchedIndex = -1;
          } else if (touchResponse?.lineBarSpots != null && touchResponse!.lineBarSpots!.isNotEmpty) {
            _touchedIndex = touchResponse.lineBarSpots!.first.x.toInt();
          }
        });
      },
      handleBuiltInTouches: true,
    );
  }
}
