import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/sensor_reading.dart';

/// BLE connection state
enum BleConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

/// BLE service for Arduino ATmega32U4 with HM-10 / Nordic UART BLE module.
///
/// Expected serial data format (sent by Arduino over BLE, newline-terminated):
///   T:98.5,H:85.2           — body temp (°F) + sweat level (%RH)
///   T:98.5,H:85.2,ET:75.0,EH:50.0  — with optional env temp + env humidity
///
/// HM-10 module UUIDs  : service FFE0, characteristic FFE1
/// Nordic UART UUIDs   : service 6E400001-…, TX char 6E400003-…
class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  // HM-10 / HC-08
  static const _hm10Service = 'ffe0';
  static const _hm10Char = 'ffe1';

  // Nordic UART Service
  static const _nordicService = '6e400001';
  static const _nordicTxChar = '6e400003'; // device → phone

  final _readingCtrl = StreamController<SensorReading>.broadcast();
  final _stateCtrl = StreamController<BleConnectionState>.broadcast();

  Stream<SensorReading> get readings => _readingCtrl.stream;
  Stream<BleConnectionState> get connectionState => _stateCtrl.stream;

  BluetoothDevice? _device;
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<List<int>>? _valueSub;
  StreamSubscription<BluetoothConnectionState>? _connStateSub;
  String _buf = '';

  BleConnectionState _state = BleConnectionState.disconnected;
  BleConnectionState get currentState => _state;
  String? get connectedDeviceName => _device?.platformName;

  void _setState(BleConnectionState s) {
    _state = s;
    _stateCtrl.add(s);
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Scan for Arduino BLE devices. Auto-connects to first match.
  Future<void> startScan() async {
    if (_state == BleConnectionState.scanning ||
        _state == BleConnectionState.connected) {
      return;
    }

    _setState(BleConnectionState.scanning);

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        for (final r in results) {
          final name = r.device.platformName.toLowerCase();
          if (name.contains('hm') ||
              name.contains('arduino') ||
              name.contains('ble') ||
              name.contains('uart') ||
              name.contains('sensor')) {
            _connectToDevice(r.device);
            return;
          }
        }
      });
    } catch (e) {
      debugPrint('BLE startScan error: $e');
      _setState(BleConnectionState.error);
    }
  }

  /// Connect to a specific device (e.g. chosen from a scanned list).
  Future<void> connectToDevice(BluetoothDevice device) =>
      _connectToDevice(device);

  /// Disconnect from current device.
  Future<void> disconnect() async {
    _valueSub?.cancel();
    _connStateSub?.cancel();
    await _device?.disconnect();
    _device = null;
    _buf = '';
    _setState(BleConnectionState.disconnected);
  }

  /// Stop an ongoing scan without connecting.
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _scanSub?.cancel();
    _scanSub = null;
    if (_state == BleConnectionState.scanning) {
      _setState(BleConnectionState.disconnected);
    }
  }

  void dispose() {
    stopScan();
    disconnect();
    _readingCtrl.close();
    _stateCtrl.close();
  }

  // ─── Internal ──────────────────────────────────────────────────────────────

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_state == BleConnectionState.connecting ||
        _state == BleConnectionState.connected) {
      return;
    }

    await stopScan();
    _setState(BleConnectionState.connecting);

    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _device = device;

      _connStateSub = device.connectionState.listen((s) {
        if (s == BluetoothConnectionState.disconnected) {
          _valueSub?.cancel();
          _connStateSub?.cancel();
          _device = null;
          _buf = '';
          _setState(BleConnectionState.disconnected);
        }
      });

      final services = await device.discoverServices();
      bool subscribed = false;

      for (final svc in services) {
        final svcId = svc.uuid.toString().toLowerCase();
        final isHm10 = svcId.contains(_hm10Service);
        final isNordic = svcId.contains(_nordicService);
        if (!isHm10 && !isNordic) continue;

        for (final ch in svc.characteristics) {
          final chId = ch.uuid.toString().toLowerCase();
          final match = (isHm10 && chId.contains(_hm10Char)) ||
              (isNordic && chId.contains(_nordicTxChar));
          if (match && (ch.properties.notify || ch.properties.indicate)) {
            await ch.setNotifyValue(true);
            _valueSub = ch.onValueReceived.listen(_onData);
            subscribed = true;
            debugPrint('BLE: subscribed to ${device.platformName} ($chId)');
            break;
          }
        }
        if (subscribed) break;
      }

      // Fallback: first notifiable characteristic
      if (!subscribed) {
        for (final svc in services) {
          for (final ch in svc.characteristics) {
            if (ch.properties.notify || ch.properties.indicate) {
              await ch.setNotifyValue(true);
              _valueSub = ch.onValueReceived.listen(_onData);
              subscribed = true;
              debugPrint('BLE: subscribed (fallback) ${device.platformName}');
              break;
            }
          }
          if (subscribed) break;
        }
      }

      if (subscribed) {
        _setState(BleConnectionState.connected);
      } else {
        await device.disconnect();
        _setState(BleConnectionState.error);
      }
    } catch (e) {
      debugPrint('BLE connect error: $e');
      _device = null;
      _setState(BleConnectionState.error);
    }
  }

  void _onData(List<int> bytes) {
    _buf += utf8.decode(bytes, allowMalformed: true);
    while (_buf.contains('\n')) {
      final nl = _buf.indexOf('\n');
      final line = _buf.substring(0, nl).trim();
      _buf = _buf.substring(nl + 1);
      if (line.isNotEmpty) {
        final r = _parseLine(line);
        if (r != null) _readingCtrl.add(r);
      }
    }
  }

  /// Parse `T:98.5,H:85.2[,ET:75.0,EH:50.0]`
  SensorReading? _parseLine(String line) {
    try {
      final kv = <String, double>{};
      for (final seg in line.split(',')) {
        final parts = seg.trim().split(':');
        if (parts.length == 2) {
          kv[parts[0].trim().toUpperCase()] = double.parse(parts[1].trim());
        }
      }
      final t = kv['T'];
      final h = kv['H'];
      if (t == null || h == null) return null;
      return SensorReading(
        id: 'ble_${DateTime.now().millisecondsSinceEpoch}',
        bodyTemperatureF: t,
        sweatLevelRh: h,
        outsideTemperatureF: kv['ET'] ?? 72.0,
        outsideHumidityRh: kv['EH'] ?? 50.0,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('BLE parse error "$line": $e');
      return null;
    }
  }
}
