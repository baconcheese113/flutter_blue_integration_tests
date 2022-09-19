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

  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BleProvider>(context, listen: true);
    void handleScanPress() async {
      if (bleProvider.scanning) {
        await bleProvider.stopScan();
      } else {
        await bleProvider.scanForNearby(onScanResult: (r) {
          print("onScanResult with ${r.id.id}");
          setState(() => _scannedDevices[r.id.id] = r);
          return false;
        });
      }
    }

    print("scanning is ${bleProvider.scanning}");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ble devices"),
        actions: [
          IconButton(
            icon: Icon(bleProvider.scanning ? Icons.search_off : Icons.search),
            onPressed: bleProvider.hasPermissions ? handleScanPress : null,
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
