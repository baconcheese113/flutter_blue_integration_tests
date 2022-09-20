import 'package:flutter/material.dart';
import 'package:flutter_blue_integration_tests/ble_provider.dart';
import 'package:flutter_blue_integration_tests/device_card.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, BluetoothDevice> _scannedDevices = {};
  late BleProvider bleProvider;

  void _handleScanPress() async {
    if (bleProvider.scanning) {
      await bleProvider.stopScan();
    } else {
      await bleProvider.scanForNearby(
          services: [Guid("65241910-0253-11e7-93ae-92361f002671")],
          onScanResult: (d) {
            setState(() => _scannedDevices[d.id.id] = d);
            return false;
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    bleProvider = Provider.of<BleProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ble devices"),
        actions: [
          IconButton(
            icon: Icon(bleProvider.scanning ? Icons.search_off : Icons.search),
            onPressed: bleProvider.hasPermissions ? _handleScanPress : null,
          ),
        ],
      ),
      body: bleProvider.hasPermissions
          ? RefreshIndicator(
              onRefresh: () async {
                setState(() => _scannedDevices.clear());
              },
              child: ListView(
                children: _scannedDevices.entries
                    .map(
                      (e) => DeviceCard(device: e.value),
                    )
                    .toList(),
              ),
            )
          : TextButton(
              onPressed: bleProvider.requestPermissions,
              child: const Text("Grant BLE Permissions"),
            ),
    );
  }
}
