import 'package:flutter/material.dart';
import 'package:flutter_blue_integration_tests/ble_provider.dart';
import 'package:flutter_blue_integration_tests/device_card_body.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class DeviceCard extends StatefulWidget {
  final BluetoothDevice device;
  const DeviceCard({Key? key, required this.device}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool _connected = false;
  BluetoothCharacteristic? _char;

  Future<void> _checkConnection() async {
    final state = await widget.device.state.first;
    setState(() => _connected = state == BluetoothDeviceState.connected);
  }

  @override
  void initState() {
    _checkConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BleProvider>(context);
    void handleConnectPress() async {
      if (_connected) {
        await widget.device.disconnect();
        if (!mounted) return;
        setState(() {
          _char = null;
          _connected = false;
        });
      } else {
        await widget.device.connect(timeout: const Duration(seconds: 3));
        await _checkConnection();
        if (!_connected) return;
        final char = await bleProvider.discoverAndGetCharacteristic(
          widget.device,
          GENERIC_ACCESS_SERVICE_UUID,
          DEVICE_NAME_CHARACTERISTIC_UUID,
        );
        if (!mounted) return;
        setState(() {
          _char = char;
          _connected = true;
        });
      }
    }

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.device.id.id),
            trailing: TextButton(
              onPressed: handleConnectPress,
              child: Text(_connected ? "Disconnect" : "Connect"),
            ),
          ),
          if (_char != null) DeviceCardBody(char: _char!),
        ],
      ),
    );
  }
}
