import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'models/sensor_reading.dart';
import 'services/notification_service.dart';
import 'services/bluetooth_service.dart';
import 'services/demo_mode_service.dart';
import 'theme/app_theme.dart';
import 'widgets/gauge_card.dart';
import 'widgets/comparison_bar.dart';
import 'widgets/trend_chart.dart';
import 'widgets/status_badge.dart';
import 'widgets/notification_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  await NotificationService().requestPermissions();
  runApp(const TempHumSenseApp());
}

class TempHumSenseApp extends StatelessWidget {
  const TempHumSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<SensorReading> _readings = [];
  final _notificationService = NotificationService();
  final _bleService = BleService();
  final _demoService = DemoModeService();

  StreamSubscription<SensorReading>? _bleSub;
  StreamSubscription<BleConnectionState>? _bleStateSub;
  StreamSubscription<SensorReading>? _demoSub;
  Timer? _uiTicker; // 1-second tick for countdown display

  BleConnectionState _bleState = BleConnectionState.disconnected;
  List<BluetoothDevice> _scannedDevices = [];
  StreamSubscription<List<ScanResult>>? _scanListSub;

  @override
  void initState() {
    super.initState();
    _bleStateSub = _bleService.connectionState.listen((s) {
      setState(() => _bleState = s);
      if (s == BleConnectionState.scanning) {
        _scannedDevices.clear();
        _scanListSub = FlutterBluePlus.scanResults.listen((results) {
          final devices = results.map((r) => r.device).toList();
          setState(() => _scannedDevices = devices);
        });
      } else {
        _scanListSub?.cancel();
      }
    });
    _bleSub = _bleService.readings.listen(_onNewReading);
  }

  @override
  void dispose() {
    _bleSub?.cancel();
    _bleStateSub?.cancel();
    _demoSub?.cancel();
    _scanListSub?.cancel();
    _uiTicker?.cancel();
    _demoService.stop();
    super.dispose();
  }

  // ─── Reading ingestion ────────────────────────────────────────────────────

  Future<void> _onNewReading(SensorReading reading) async {
    final status = reading.thresholdStatus;
    if (status.hasAlert) {
      await _notificationService.processThresholdAlerts(status);
    }
    if (mounted) {
      setState(() => _readings.insert(0, reading));
    }
  }

  // ─── Demo mode ────────────────────────────────────────────────────────────

  void _startDemo() {
    if (_demoService.isRunning) return;
    _demoSub?.cancel();
    _demoSub = _demoService.readings.listen(_onNewReading);
    _demoService.start();
    _uiTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    setState(() {});
  }

  void _stopDemo() {
    _demoService.stop();
    _demoSub?.cancel();
    _uiTicker?.cancel();
    setState(() {});
  }

  // ─── BLE ─────────────────────────────────────────────────────────────────

  void _showBleSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BleSheet(
        bleService: _bleService,
        bleState: _bleState,
        scannedDevices: _scannedDevices,
      ),
    );
  }

  // ─── Manual reading ───────────────────────────────────────────────────────

  void _showAddReadingModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddReadingModal(onSave: _addManualReading),
    );
  }

  void _addManualReading(
      double bodyTemp, double sweatRh, double outsideTemp, double outsideRh) {
    final reading = SensorReading(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      bodyTemperatureF: bodyTemp,
      sweatLevelRh: sweatRh,
      outsideTemperatureF: outsideTemp,
      outsideHumidityRh: outsideRh,
      timestamp: DateTime.now(),
    );
    _onNewReading(reading);
    Navigator.pop(context);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final latest = _readings.isNotEmpty ? _readings.first : null;
    final recentReadings = _readings.take(20).toList().reversed.toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppTheme.background),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.amberDark.withOpacity(0.1),
                      Colors.transparent,
                      AppTheme.cyanDark.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: latest == null
                  ? _buildEmptyState()
                  : _buildDashboard(latest, recentReadings),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReadingModal,
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.cardBorder, width: 1),
        ),
        child: const Icon(Icons.add, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: const Icon(Icons.thermostat,
                color: AppTheme.textTertiary, size: 32),
          ),
          const SizedBox(height: 24),
          const Text('No readings yet',
              style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 18,
                  fontWeight: FontWeight.w300)),
          const SizedBox(height: 8),
          const Text('Connect via Bluetooth or start Demo Mode',
              style:
                  TextStyle(color: AppTheme.textTertiary, fontSize: 14)),
          const SizedBox(height: 24),
          // Control row
          _buildControlRow(),
        ],
      ),
    );
  }

  Widget _buildControlRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // BLE button
        _ControlButton(
          icon: Icons.bluetooth,
          label: _bleBtnLabel(),
          color: _bleBtnColor(),
          onTap: _bleState == BleConnectionState.connected
              ? () => _bleService.disconnect()
              : _showBleSheet,
        ),
        const SizedBox(width: 12),
        // Demo mode button
        _ControlButton(
          icon: _demoService.isRunning ? Icons.stop : Icons.play_arrow,
          label: _demoBtnLabel(),
          color: _demoService.isRunning ? Colors.orange : AppTheme.emerald,
          onTap: _demoService.isRunning ? _stopDemo : _startDemo,
        ),
      ],
    );
  }

  String _bleBtnLabel() {
    switch (_bleState) {
      case BleConnectionState.scanning:
        return 'Scanning…';
      case BleConnectionState.connecting:
        return 'Connecting…';
      case BleConnectionState.connected:
        return _bleService.connectedDeviceName ?? 'Connected';
      case BleConnectionState.error:
        return 'BLE Error';
      case BleConnectionState.disconnected:
        return 'Connect BLE';
    }
  }

  Color _bleBtnColor() {
    switch (_bleState) {
      case BleConnectionState.connected:
        return AppTheme.emerald;
      case BleConnectionState.error:
        return Colors.red;
      default:
        return AppTheme.cyan;
    }
  }

  String _demoBtnLabel() {
    if (_demoService.isRunning) {
      return 'Demo #${_demoService.currentIndex + 1}/${_demoService.totalReadings} (${_demoService.secondsLeft}s)';
    }
    return 'Demo Mode';
  }

  Widget _buildDashboard(
      SensorReading latest, List<SensorReading> recentReadings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.emerald.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.circle,
                                  color: AppTheme.emerald, size: 8),
                              const SizedBox(width: 6),
                              const Text('LIVE MONITOR',
                                  style: TextStyle(
                                      color: AppTheme.emerald,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Sensor Dashboard',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w300)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            color: AppTheme.textTertiary, size: 14),
                        const SizedBox(width: 6),
                        Text('Last: ${_formatTime(latest.timestamp)}',
                            style: const TextStyle(
                                color: AppTheme.textTertiary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                // Control buttons
                _buildControlRow(),
              ],
            ),

            // Demo countdown banner
            if (_demoService.isRunning) ...[
              const SizedBox(height: 12),
              _DemoCountdownBanner(
                index: _demoService.currentIndex,
                total: _demoService.totalReadings,
                secondsLeft: _demoService.secondsLeft,
                onStop: _stopDemo,
              ),
            ],

            const SizedBox(height: 24),
            NotificationBanner(latestReading: latest),
            StatusBadge(
              bodyTemp: latest.bodyTemperatureF,
              sweatRH: latest.sweatLevelRh,
              outsideTemp: latest.outsideTemperatureF,
              outsideRH: latest.outsideHumidityRh,
            ),
            const SizedBox(height: 24),

            // Main gauges
            LayoutBuilder(builder: (ctx, constraints) {
              final wide = constraints.maxWidth > 600;
              return Flex(
                direction: wide ? Axis.horizontal : Axis.vertical,
                children: [
                  Expanded(
                    child: GaugeCard(
                      label: 'Body Temperature',
                      value: latest.bodyTemperatureF,
                      unit: '°F',
                      icon: Icons.thermostat,
                      min: 90,
                      max: 110,
                      color: AppTheme.amber,
                      subLabel: 'Range',
                      subValue: '90–110 °F',
                    ),
                  ),
                  SizedBox(width: wide ? 16 : 0, height: wide ? 0 : 16),
                  Expanded(
                    child: GaugeCard(
                      label: 'Sweat Level',
                      value: latest.sweatLevelRh,
                      unit: '%RH',
                      icon: Icons.water_drop,
                      min: 0,
                      max: 100,
                      color: AppTheme.cyan,
                      subLabel: 'Range',
                      subValue: '0–100 %RH',
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),

            // Comparison bars
            LayoutBuilder(builder: (ctx, constraints) {
              final wide = constraints.maxWidth > 600;
              return Flex(
                direction: wide ? Axis.horizontal : Axis.vertical,
                children: [
                  Expanded(
                    child: ComparisonBar(
                      bodyValue: latest.bodyTemperatureF,
                      outsideValue: latest.outsideTemperatureF,
                      unit: '°F',
                      label: 'Temperature',
                      color: AppTheme.amber,
                    ),
                  ),
                  SizedBox(width: wide ? 16 : 0, height: wide ? 0 : 16),
                  Expanded(
                    child: ComparisonBar(
                      bodyValue: latest.sweatLevelRh,
                      outsideValue: latest.outsideHumidityRh,
                      unit: '%RH',
                      label: 'Humidity',
                      color: AppTheme.cyan,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),

            // Trend charts
            LayoutBuilder(builder: (ctx, constraints) {
              final wide = constraints.maxWidth > 600;
              return Flex(
                direction: wide ? Axis.horizontal : Axis.vertical,
                children: [
                  Expanded(
                      child: TrendChart(
                          data: recentReadings, type: 'temperature')),
                  SizedBox(width: wide ? 16 : 0, height: wide ? 0 : 16),
                  Expanded(
                      child: TrendChart(
                          data: recentReadings, type: 'humidity')),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Recent readings table
            Container(
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
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RECENT READINGS',
                      style: TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.15)),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(Colors.transparent),
                      dataRowColor:
                          WidgetStateProperty.all(Colors.transparent),
                      horizontalMargin: 0,
                      columnSpacing: 16,
                      columns: const [
                        DataColumn(
                            label: Text('Time',
                                style: TextStyle(
                                    color: AppTheme.textTertiary,
                                    fontSize: 11))),
                        DataColumn(
                            label: Text('Body °F',
                                style: TextStyle(
                                    color: AppTheme.textTertiary,
                                    fontSize: 11)),
                            numeric: true),
                        DataColumn(
                            label: Text('Sweat %RH',
                                style: TextStyle(
                                    color: AppTheme.textTertiary,
                                    fontSize: 11)),
                            numeric: true),
                        DataColumn(
                            label: Text('Outside °F',
                                style: TextStyle(
                                    color: AppTheme.textTertiary,
                                    fontSize: 11)),
                            numeric: true),
                        DataColumn(
                            label: Text('Outside %RH',
                                style: TextStyle(
                                    color: AppTheme.textTertiary,
                                    fontSize: 11)),
                            numeric: true),
                        DataColumn(
                            label: Text('Δ Temp',
                                style: TextStyle(
                                    color: AppTheme.textTertiary,
                                    fontSize: 11)),
                            numeric: true),
                        DataColumn(
                            label: Text('Δ Humidity',
                                style: TextStyle(
                                    color: AppTheme.textTertiary,
                                    fontSize: 11)),
                            numeric: true),
                      ],
                      rows: _readings.take(10).map((r) {
                        return DataRow(cells: [
                          DataCell(Text(_formatDateTime(r.timestamp),
                              style: const TextStyle(
                                  color: AppTheme.textTertiary,
                                  fontSize: 12))),
                          DataCell(Text(r.bodyTemperatureF.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: AppTheme.amberLight, fontSize: 12))),
                          DataCell(Text(r.sweatLevelRh.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: AppTheme.cyanLight, fontSize: 12))),
                          DataCell(Text(
                              r.outsideTemperatureF.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12))),
                          DataCell(Text(r.outsideHumidityRh.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12))),
                          DataCell(Text(
                              '${r.tempDifference > 0 ? '+' : ''}${r.tempDifference.toStringAsFixed(1)}',
                              style: TextStyle(
                                  color: r.tempDifference > 0
                                      ? AppTheme.amber
                                      : AppTheme.cyan,
                                  fontSize: 12))),
                          DataCell(Text(
                              '${r.humidityDifference > 0 ? '+' : ''}${r.humidityDifference.toStringAsFixed(1)}',
                              style: TextStyle(
                                  color: r.humidityDifference > 0
                                      ? AppTheme.cyan
                                      : Colors.blue,
                                  fontSize: 12))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  String _formatDateTime(DateTime t) =>
      DateFormat('MMM d, HH:mm').format(t);
}

// ─── Small control button ─────────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─── Demo countdown banner ───────────────────────────────────────────────────

class _DemoCountdownBanner extends StatelessWidget {
  final int index;
  final int total;
  final int secondsLeft;
  final VoidCallback onStop;

  const _DemoCountdownBanner({
    required this.index,
    required this.total,
    required this.secondsLeft,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_outline, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo Mode — Reading ${index + 1} of $total  •  next in ${secondsLeft}s',
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: onStop,
            child: const Icon(Icons.stop_circle_outlined,
                color: Colors.orange, size: 18),
          ),
        ],
      ),
    );
  }
}

// ─── BLE bottom sheet ─────────────────────────────────────────────────────────

class _BleSheet extends StatelessWidget {
  final BleService bleService;
  final BleConnectionState bleState;
  final List<BluetoothDevice> scannedDevices;

  const _BleSheet({
    required this.bleService,
    required this.bleState,
    required this.scannedDevices,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Bluetooth',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w500)),
              _statusChip(bleState),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Connects to Arduino ATmega32U4 via HM-10 or Nordic UART BLE.\n'
            'Arduino should send: T:98.5,H:85.2\\n',
            style:
                TextStyle(color: AppTheme.textTertiary, fontSize: 12),
          ),
          const SizedBox(height: 20),
          if (bleState == BleConnectionState.connected) ...[
            Text('Connected to: ${bleService.connectedDeviceName ?? 'Device'}',
                style: const TextStyle(
                    color: AppTheme.emerald, fontSize: 14)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  bleService.disconnect();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.bluetooth_disabled, size: 16),
                label: const Text('Disconnect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: bleState == BleConnectionState.scanning ||
                        bleState == BleConnectionState.connecting
                    ? null
                    : () => bleService.startScan(),
                icon: bleState == BleConnectionState.scanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.cyan))
                    : const Icon(Icons.search, size: 16),
                label: Text(bleState == BleConnectionState.scanning
                    ? 'Scanning…'
                    : 'Scan for Device'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cyan.withOpacity(0.15),
                  foregroundColor: AppTheme.cyan,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (scannedDevices.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Found devices:',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              ...scannedDevices.map((d) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bluetooth,
                        color: AppTheme.cyan, size: 20),
                    title: Text(
                        d.platformName.isEmpty ? 'Unknown' : d.platformName,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 13)),
                    subtitle: Text(d.remoteId.toString(),
                        style: const TextStyle(
                            color: AppTheme.textTertiary, fontSize: 11)),
                    onTap: () {
                      bleService.connectToDevice(d);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _statusChip(BleConnectionState state) {
    Color c;
    String label;
    switch (state) {
      case BleConnectionState.connected:
        c = AppTheme.emerald;
        label = 'Connected';
        break;
      case BleConnectionState.scanning:
        c = AppTheme.cyan;
        label = 'Scanning';
        break;
      case BleConnectionState.connecting:
        c = AppTheme.amber;
        label = 'Connecting';
        break;
      case BleConnectionState.error:
        c = Colors.red;
        label = 'Error';
        break;
      default:
        c = AppTheme.textTertiary;
        label = 'Off';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(color: c, fontSize: 11)),
    );
  }
}

// ─── Manual add reading modal ────────────────────────────────────────────────

class _AddReadingModal extends StatefulWidget {
  final Function(double, double, double, double) onSave;

  const _AddReadingModal({required this.onSave});

  @override
  State<_AddReadingModal> createState() => _AddReadingModalState();
}

class _AddReadingModalState extends State<_AddReadingModal> {
  final _bodyTempCtrl = TextEditingController(text: '97.0');
  final _sweatRhCtrl = TextEditingController(text: '65.0');
  final _outsideTempCtrl = TextEditingController(text: '85.0');
  final _outsideRhCtrl = TextEditingController(text: '50.0');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manual Reading',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          _field('Body Temperature (°F)', _bodyTempCtrl, AppTheme.amber),
          const SizedBox(height: 16),
          _field('Sweat Level (%RH)', _sweatRhCtrl, AppTheme.cyan),
          const SizedBox(height: 16),
          _field('Outside Temperature (°F)', _outsideTempCtrl,
              AppTheme.textSecondary),
          const SizedBox(height: 16),
          _field('Outside Humidity (%RH)', _outsideRhCtrl,
              AppTheme.textSecondary),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => widget.onSave(
                  double.tryParse(_bodyTempCtrl.text) ?? 97.0,
                  double.tryParse(_sweatRhCtrl.text) ?? 65.0,
                  double.tryParse(_outsideTempCtrl.text) ?? 85.0,
                  double.tryParse(_outsideRhCtrl.text) ?? 50.0,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emerald,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, Color accent) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: accent),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textTertiary),
        filled: true,
        fillColor: AppTheme.cardBackground,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.cardBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.cardBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accent)),
      ),
    );
  }

  @override
  void dispose() {
    _bodyTempCtrl.dispose();
    _sweatRhCtrl.dispose();
    _outsideTempCtrl.dispose();
    _outsideRhCtrl.dispose();
    super.dispose();
  }
}
