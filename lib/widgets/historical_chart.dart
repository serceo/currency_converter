import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HistoricalChart extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (chartData.isEmpty || !chartData.containsKey('rates')) {
      return const Center(
        child: Text('No chart data available'),
      );
    }

    try {
      // Process chart data
      final Map<String, dynamic> rates = chartData['rates'];
      final List<FlSpot> spots = [];
      final List<String> dates = [];

      // Sort dates to ensure chronological order
      final sortedDates = rates.keys.toList()..sort();

      // Create data points for the chart
      for (int i = 0; i < sortedDates.length; i++) {
        final date = sortedDates[i];
        if (rates[date] != null && rates[date][toCurrency] != null) {
          final rate = rates[date][toCurrency].toDouble();
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
      double minY =
          spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) * 0.95;
      double maxY =
          spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.05;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Exchange Rate: $fromCurrency to $toCurrency',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: (maxY - minY) / 5,
                  verticalInterval: 1,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        // Show only some dates to avoid overcrowding
                        if (value.toInt() % (dates.length ~/ 5 + 1) == 0 &&
                            value.toInt() < dates.length) {
                          final date = dates[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('MM-dd').format(DateTime.parse(date)),
                              style: const TextStyle(
                                fontSize: 10,
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
                          value.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Theme.of(context).colorScheme.surface,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final index = barSpot.x.toInt();
                        if (index >= 0 && index < dates.length) {
                          final date = dates[index];
                          final formattedDate = DateFormat('yyyy-MM-dd')
                              .format(DateTime.parse(date));
                          return LineTooltipItem(
                            '$formattedDate\n${barSpot.y.toStringAsFixed(4)} $toCurrency',
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
                ),
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return Center(
        child: Text('Error rendering chart: ${e.toString()}'),
      );
    }
  }
}
