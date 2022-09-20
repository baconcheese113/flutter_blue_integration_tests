import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceCardBody extends StatefulWidget {
  final BluetoothCharacteristic char;
  const DeviceCardBody({Key? key, required this.char}) : super(key: key);

  @override
  State<DeviceCardBody> createState() => _DeviceCardBodyState();
}

class _DeviceCardBodyState extends State<DeviceCardBody> {
  String _curCharVal = "";
  StreamSubscription<List<int>>? _notifySub;
  final TextEditingController _controller = TextEditingController();

  void _handleCharRead() async {
    final bytes = await widget.char.read();
    setState(() => _curCharVal = utf8.decode(bytes));
  }

  void _handleCharWrite() async {
    await widget.char.write(utf8.encode(_controller.text));
    _controller.clear();
  }

  void _handleToggleNotify() async {
    if (_notifySub != null) {
      await widget.char.setNotifyValue(false);
      await _notifySub!.cancel();
      setState(() => _notifySub = null);
    } else {
      await widget.char.setNotifyValue(true);
      final notifySub = widget.char.onValueChangedStream.listen((v) {
        if (!mounted) {
          _notifySub!.cancel();
          return;
        }
        setState(() => _curCharVal = utf8.decode(v));
      });
      setState(() => _notifySub = notifySub);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          TextButton(onPressed: _handleCharRead, child: const Text("Read")),
          Text(_curCharVal, key: const ValueKey("text.read")),
        ]),
        Row(children: [
          Expanded(
            child: TextField(
              key: const ValueKey("textField.write"),
              controller: _controller,
            ),
          ),
          TextButton(onPressed: _handleCharWrite, child: const Text("Write")),
        ]),
        TextButton(
          key: const ValueKey("button.notify"),
          onPressed: _handleToggleNotify,
          child: Text("${_notifySub == null ? "Enable" : "Disable"} notify"),
        )
      ],
    );
  }
}
