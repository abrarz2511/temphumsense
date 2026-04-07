import 'package:flutter/material.dart';
import '../services/threshold_service.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final double bodyTemp;
  final double sweatRH;
  final double? outsideTemp;
  final double? outsideRH;

  const StatusBadge({
    super.key,
    required this.bodyTemp,
    required this.sweatRH,
    this.outsideTemp,
    this.outsideRH,
  });

  @override
  Widget build(BuildContext context) {
    final status = ThresholdService.evaluateSensorReadings(
      bodyTemperatureF: bodyTemp,
      sweatLevelRh: sweatRH,
    );

    final Color statusColor;
    final String statusText;
    final IconData statusIcon;

    switch (status.overallStatus) {
      case ThresholdResult.alert:
        statusColor = AppTheme.red;
        statusText = 'ALERT';
        statusIcon = Icons.warning;
      case ThresholdResult.warning:
        statusColor = AppTheme.warning;
        statusText = 'WARNING';
        statusIcon = Icons.info;
      case ThresholdResult.normal:
        statusColor = AppTheme.emerald;
        statusText = 'NORMAL';
        statusIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor, size: 18),
          const SizedBox(width: 8),
          Text(
            'Status: $statusText',
            style: TextStyle(
              color: statusColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          if (status.hasAlert || status.hasWarning) ...[
            const SizedBox(width: 8),
            Text(
              _getAlertDetail(status),
              style: TextStyle(
                color: statusColor.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getAlertDetail(SensorThresholdStatus status) {
    if (status.hasAlert) {
      final alerts = <String>[];
      if (status.temperatureStatus == ThresholdResult.alert) {
        alerts.add('High Temp');
      }
      if (status.sweatLevelStatus == ThresholdResult.alert) {
        alerts.add('High Sweat');
      }
      return alerts.join(', ');
    }
    return 'Approaching threshold';
  }
}