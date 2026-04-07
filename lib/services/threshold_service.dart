/// Threshold configuration and checking service.
///
/// This service handles all threshold-related logic for the sensor readings.
/// Thresholds are defined as per CLAUDE.md:
/// - Temperature threshold: 98°F (body temperature)
/// - Sweat level threshold: 90%RH
class ThresholdService {
  // Threshold constants as per CLAUDE.md
  static const double temperatureThreshold = 98.0; // Fahrenheit
  static const double sweatLevelThreshold = 90.0; // %RH

  // Warning thresholds (approaching danger zone)
  static const double temperatureWarningThreshold = 96.0; // 2°F below alert
  static const double sweatLevelWarningThreshold = 80.0; // 10%RH below alert

  /// Check if a temperature reading exceeds the threshold
  static ThresholdResult checkTemperature(double temperatureF) {
    if (temperatureF > temperatureThreshold) {
      return ThresholdResult.alert;
    } else if (temperatureF > temperatureWarningThreshold) {
      return ThresholdResult.warning;
    }
    return ThresholdResult.normal;
  }

  /// Check if a sweat level reading exceeds the threshold
  static ThresholdResult checkSweatLevel(double sweatLevelRh) {
    if (sweatLevelRh > sweatLevelThreshold) {
      return ThresholdResult.alert;
    } else if (sweatLevelRh > sweatLevelWarningThreshold) {
      return ThresholdResult.warning;
    }
    return ThresholdResult.normal;
  }

  /// Evaluate all sensor readings and return combined result
  static SensorThresholdStatus evaluateSensorReadings({
    required double bodyTemperatureF,
    required double sweatLevelRh,
  }) {
    final tempResult = checkTemperature(bodyTemperatureF);
    final sweatResult = checkSweatLevel(sweatLevelRh);

    return SensorThresholdStatus(
      temperatureStatus: tempResult,
      sweatLevelStatus: sweatResult,
      overallStatus: _getOverallStatus(tempResult, sweatResult),
      temperatureExceededBy: bodyTemperatureF > temperatureThreshold
          ? bodyTemperatureF - temperatureThreshold
          : null,
      sweatLevelExceededBy: sweatLevelRh > sweatLevelThreshold
          ? sweatLevelRh - sweatLevelThreshold
          : null,
    );
  }

  /// Determine overall status based on individual results
  static ThresholdResult _getOverallStatus(
    ThresholdResult tempResult,
    ThresholdResult sweatResult,
  ) {
    // If any is alert, overall is alert
    if (tempResult == ThresholdResult.alert ||
        sweatResult == ThresholdResult.alert) {
      return ThresholdResult.alert;
    }
    // If any is warning, overall is warning
    if (tempResult == ThresholdResult.warning ||
        sweatResult == ThresholdResult.warning) {
      return ThresholdResult.warning;
    }
    return ThresholdResult.normal;
  }

  /// Get threshold configuration info
  static ThresholdConfig get config => ThresholdConfig(
        temperatureThreshold: temperatureThreshold,
        sweatLevelThreshold: sweatLevelThreshold,
        temperatureWarningThreshold: temperatureWarningThreshold,
        sweatLevelWarningThreshold: sweatLevelWarningThreshold,
      );
}

/// Result of threshold check
enum ThresholdResult {
  normal,
  warning,
  alert,
}

/// Combined status of all sensor threshold checks
class SensorThresholdStatus {
  final ThresholdResult temperatureStatus;
  final ThresholdResult sweatLevelStatus;
  final ThresholdResult overallStatus;
  final double? temperatureExceededBy;
  final double? sweatLevelExceededBy;

  const SensorThresholdStatus({
    required this.temperatureStatus,
    required this.sweatLevelStatus,
    required this.overallStatus,
    this.temperatureExceededBy,
    this.sweatLevelExceededBy,
  });

  bool get hasAlert => overallStatus == ThresholdResult.alert;
  bool get hasWarning => overallStatus == ThresholdResult.warning;
  bool get isNormal => overallStatus == ThresholdResult.normal;

  /// Get alert message if threshold exceeded
  String? get alertMessage {
    if (!hasAlert) return null;

    final messages = <String>[];
    if (temperatureStatus == ThresholdResult.alert) {
      messages.add(
          'Body temperature exceeded threshold by ${temperatureExceededBy?.toStringAsFixed(1)}°F');
    }
    if (sweatLevelStatus == ThresholdResult.alert) {
      messages.add(
          'Sweat level exceeded threshold by ${sweatLevelExceededBy?.toStringAsFixed(1)}%RH');
    }
    return messages.join(' and ');
  }
}

/// Configuration values for thresholds
class ThresholdConfig {
  final double temperatureThreshold;
  final double sweatLevelThreshold;
  final double temperatureWarningThreshold;
  final double sweatLevelWarningThreshold;

  const ThresholdConfig({
    required this.temperatureThreshold,
    required this.sweatLevelThreshold,
    required this.temperatureWarningThreshold,
    required this.sweatLevelWarningThreshold,
  });
}