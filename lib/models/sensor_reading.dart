import '../services/threshold_service.dart';

/// Represents a single sensor reading from the temperature/humidity device.
class SensorReading {
  final String id;
  final double bodyTemperatureF;
  final double sweatLevelRh;
  final double outsideTemperatureF;
  final double outsideHumidityRh;
  final DateTime timestamp;

  SensorReading({
    required this.id,
    required this.bodyTemperatureF,
    required this.sweatLevelRh,
    required this.outsideTemperatureF,
    required this.outsideHumidityRh,
    required this.timestamp,
  });

  /// Evaluate this reading against threshold values
  SensorThresholdStatus get thresholdStatus => ThresholdService.evaluateSensorReadings(
        bodyTemperatureF: bodyTemperatureF,
        sweatLevelRh: sweatLevelRh,
      );

  // Convenience getters using threshold service
  bool get isTempHigh => bodyTemperatureF > ThresholdService.temperatureThreshold;
  bool get isSweatHigh => sweatLevelRh > ThresholdService.sweatLevelThreshold;
  bool get hasAlert => isTempHigh || isSweatHigh;

  /// Check if temperature is in warning zone (approaching threshold)
  bool get isTempWarning =>
      bodyTemperatureF > ThresholdService.temperatureWarningThreshold &&
      bodyTemperatureF <= ThresholdService.temperatureThreshold;

  /// Check if sweat level is in warning zone (approaching threshold)
  bool get isSweatWarning =>
      sweatLevelRh > ThresholdService.sweatLevelWarningThreshold &&
      sweatLevelRh <= ThresholdService.sweatLevelThreshold;

  /// Whether any reading is in warning state
  bool get hasWarning => isTempWarning || isSweatWarning;

  // Difference calculations
  double get tempDifference => bodyTemperatureF - outsideTemperatureF;
  double get humidityDifference => sweatLevelRh - outsideHumidityRh;

  /// How much temperature exceeds threshold (null if not exceeded)
  double? get tempExceededBy => isTempHigh
      ? bodyTemperatureF - ThresholdService.temperatureThreshold
      : null;

  /// How much sweat level exceeds threshold (null if not exceeded)
  double? get sweatExceededBy => isSweatHigh
      ? sweatLevelRh - ThresholdService.sweatLevelThreshold
      : null;

  /// Create a copy with updated values
  SensorReading copyWith({
    String? id,
    double? bodyTemperatureF,
    double? sweatLevelRh,
    double? outsideTemperatureF,
    double? outsideHumidityRh,
    DateTime? timestamp,
  }) {
    return SensorReading(
      id: id ?? this.id,
      bodyTemperatureF: bodyTemperatureF ?? this.bodyTemperatureF,
      sweatLevelRh: sweatLevelRh ?? this.sweatLevelRh,
      outsideTemperatureF: outsideTemperatureF ?? this.outsideTemperatureF,
      outsideHumidityRh: outsideHumidityRh ?? this.outsideHumidityRh,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body_temperature_f': bodyTemperatureF,
      'sweat_level_rh': sweatLevelRh,
      'outside_temperature_f': outsideTemperatureF,
      'outside_humidity_rh': outsideHumidityRh,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      id: json['id'] as String,
      bodyTemperatureF: (json['body_temperature_f'] as num).toDouble(),
      sweatLevelRh: (json['sweat_level_rh'] as num).toDouble(),
      outsideTemperatureF: (json['outside_temperature_f'] as num).toDouble(),
      outsideHumidityRh: (json['outside_humidity_rh'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'SensorReading(id: $id, bodyTemp: ${bodyTemperatureF}°F, sweat: ${sweatLevelRh}%RH, status: ${thresholdStatus.overallStatus})';
  }
}