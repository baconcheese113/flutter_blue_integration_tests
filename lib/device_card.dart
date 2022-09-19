import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceCard extends StatefulWidget {
  final BluetoothDevice device;
  const DeviceCard({Key? key, required this.device}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool _isConnected = false;

  void _handleConnectPress() async {
    if (_isConnected) {
      await widget.device.disconnect();
      setState(() => _isConnected = false);
      print("disconnected");
    } else {
      await widget.device.connect();
      setState(() => _isConnected = true);
      print("connected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(widget.device.id.id),
        trailing: TextButton(
          onPressed: _handleConnectPress,
          child: Text(_isConnected ? "Disconnect" : "Connect"),
        ),
      ),
    );
  }
}
