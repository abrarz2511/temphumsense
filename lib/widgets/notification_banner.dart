import 'package:flutter/material.dart';
import '../models/sensor_reading.dart';
import '../services/threshold_service.dart';
import '../theme/app_theme.dart';

class NotificationBanner extends StatelessWidget {
  final SensorReading latestReading;

  const NotificationBanner({
    super.key,
    required this.latestReading,
  });

  @override
  Widget build(BuildContext context) {
    final status = latestReading.thresholdStatus;

    if (!status.hasAlert) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.red.withOpacity(0.2),
            AppTheme.red.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.red.withOpacity(0.4), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.red.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber,
              color: AppTheme.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Threshold Exceeded',
                  style: TextStyle(
                    color: AppTheme.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getMessage(status),
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Dismiss action - could be implemented with state management
            },
            icon: Icon(
              Icons.close,
              color: AppTheme.textTertiary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  String _getMessage(SensorThresholdStatus status) {
    final messages = <String>[];

    if (status.temperatureStatus == ThresholdResult.alert) {
      final exceeded = status.temperatureExceededBy ?? 0;
      messages.add(
          'Body temperature ${latestReading.bodyTemperatureF.toStringAsFixed(1)}°F '
          'exceeds ${ThresholdService.temperatureThreshold.toStringAsFixed(0)}°F threshold '
          'by ${exceeded.toStringAsFixed(1)}°F');
    }

    if (status.sweatLevelStatus == ThresholdResult.alert) {
      final exceeded = status.sweatLevelExceededBy ?? 0;
      messages.add(
          'Sweat level ${latestReading.sweatLevelRh.toStringAsFixed(1)}%RH '
          'exceeds ${ThresholdService.sweatLevelThreshold.toStringAsFixed(0)}%RH threshold '
          'by ${exceeded.toStringAsFixed(1)}%RH');
    }

    return messages.join(' • ');
  }
}