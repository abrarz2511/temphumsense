import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/sensor_reading.dart';
import '../theme/app_theme.dart';

class TrendChart extends StatelessWidget {
  final List<SensorReading> data;
  final String type; // 'temperature' or 'humidity'

  const TrendChart({
    super.key,
    required this.data,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isTemperature = type == 'temperature';
    final color = isTemperature ? AppTheme.amber : AppTheme.cyan;
    final label = isTemperature ? 'Temperature Trend' : 'Humidity Trend';
    final unit = isTemperature ? '°F' : '%RH';

    // Get the relevant values
    final spots = data.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final value = isTemperature
          ? entry.value.bodyTemperatureF
          : entry.value.sweatLevelRh;
      return FlSpot(index, value);
    }).toList();

    // Calculate min/max for Y axis
    final values = data.map((r) {
      return isTemperature ? r.bodyTemperatureF : r.sweatLevelRh;
    }).toList();

    final minY = values.isEmpty ? 0.0 : values.reduce((a, b) => a < b ? a : b).toDouble() - 5;
    final maxY = values.isEmpty ? 100.0 : values.reduce((a, b) => a > b ? a : b).toDouble() + 5;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardBackground,
            AppTheme.cardBackground.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isTemperature ? Icons.thermostat : Icons.water_drop,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: data.isEmpty
                ? const Center(
                    child: Text(
                      'No data',
                      style: TextStyle(color: AppTheme.textTertiary),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: (maxY - minY) / 4,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppTheme.cardBorder,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: const FlTitlesData(
                        show: false,
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (data.length - 1).toDouble(),
                      minY: minY,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: color,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: color.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}