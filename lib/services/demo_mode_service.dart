import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sensor_reading.dart';

/// ──────────────────────────────────────────────────────────────────────────
/// Demo mode: plays 4 preset readings one per minute without needing a device.
///
/// REPLACE the values below with your actual 4 sensor readings.
/// Format: bodyTemperatureF (°F), sweatLevelRh (%RH),
///         outsideTemperatureF (°F), outsideHumidityRh (%RH)
/// ──────────────────────────────────────────────────────────────────────────
class DemoModeService {
  static final DemoModeService _instance = DemoModeService._internal();
  factory DemoModeService() => _instance;
  DemoModeService._internal();

  // ── 4 demo readings — replace with your actual values ──────────────────
  static const List<_Entry> _data = [
    _Entry(bodyF: 97.5, sweatRh: 65.0, envF: 72.0, envRh: 45.0), // Reading 1
    _Entry(bodyF: 97.8, sweatRh: 82.0, envF: 73.0, envRh: 50.0), // Reading 2
    _Entry(bodyF: 99.2, sweatRh: 85.0, envF: 74.0, envRh: 52.0), // Reading 3
    _Entry(bodyF: 99.8, sweatRh: 92.5, envF: 75.0, envRh: 55.0), // Reading 4
  ];
  // ────────────────────────────────────────────────────────────────────────

  static const int intervalSeconds = 60;

  final _readingCtrl = StreamController<SensorReading>.broadcast();
  Stream<SensorReading> get readings => _readingCtrl.stream;

  Timer? _ticker;
  int _idx = 0;
  bool _running = false;
  int _secondsLeft = 0;

  bool get isRunning => _running;
  int get currentIndex => _idx;
  int get secondsLeft => _secondsLeft;
  int get totalReadings => _data.length;

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Start demo: emits first reading immediately, then one every 60 s.
  void start() {
    if (_running) return;
    _running = true;
    _idx = 0;
    _emit();
    _startTicker();
  }

  /// Stop demo mode.
  void stop() {
    _ticker?.cancel();
    _ticker = null;
    _running = false;
    _secondsLeft = 0;
  }

  void dispose() {
    stop();
    _readingCtrl.close();
  }

  // ─── Internal ────────────────────────────────────────────────────────────

  void _startTicker() {
    _secondsLeft = intervalSeconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsLeft--;
      if (_secondsLeft <= 0) {
        _idx++;
        if (_idx >= _data.length) {
          stop();
          debugPrint('DemoMode: all ${_data.length} readings played.');
          return;
        }
        _emit();
        _secondsLeft = intervalSeconds;
      }
    });
  }

  void _emit() {
    final e = _data[_idx];
    final r = SensorReading(
      id: 'demo_${_idx}_${DateTime.now().millisecondsSinceEpoch}',
      bodyTemperatureF: e.bodyF,
      sweatLevelRh: e.sweatRh,
      outsideTemperatureF: e.envF,
      outsideHumidityRh: e.envRh,
      timestamp: DateTime.now(),
    );
    _readingCtrl.add(r);
    debugPrint(
        'DemoMode: #${_idx + 1}/${_data.length} '
        '— ${e.bodyF}°F / ${e.sweatRh}%RH');
  }
}

class _Entry {
  final double bodyF;
  final double sweatRh;
  final double envF;
  final double envRh;
  const _Entry({
    required this.bodyF,
    required this.sweatRh,
    required this.envF,
    required this.envRh,
  });
}
