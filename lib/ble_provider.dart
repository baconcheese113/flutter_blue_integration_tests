import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleProvider extends ChangeNotifier {
  final _flutterBlue = FlutterBluePlus.instance;
  bool scanning = false;
  bool hasPermissions = false;

  Future<bool> _hasPermission(Permission perm) async {
    PermissionStatus status = await perm.status;
    print("Current status for ${perm.toString()} is $status");
    return status.isGranted;
  }

  Future<bool> _requestPermission(Permission perm) async {
    if (!await _hasPermission(perm)) {
      print("${perm.toString()} was not granted");
      if (!await perm.request().isGranted) {
        print("Andddd, they denied me again!");
        return false;
      }
    }
    return true;
  }

  Future<bool> _tryPowerOnBle() async {
    print("about to turn on bluetooth");
    if (!await _flutterBlue.isOn) {
      bool isNowOn = await _flutterBlue.turnOn();
      if (!isNowOn) {
        print("Unable to turn on bluetooth");
        return false;
      }
    }
    return true;
  }

  Future<void> checkPermissions() async {
    if (Platform.isAndroid) {
      if (!await _hasPermission(Permission.location) ||
          !await _hasPermission(Permission.bluetoothScan) ||
          !await _hasPermission(Permission.bluetoothConnect)) {
        hasPermissions = false;
        notifyListeners();
        return;
      }
    }
    hasPermissions = true;
    notifyListeners();
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      if (!await _requestPermission(Permission.location) ||
          !await _requestPermission(Permission.bluetoothScan) ||
          !await _requestPermission(Permission.bluetoothConnect)) {
        hasPermissions = false;
        return false;
      }
    }
    hasPermissions = true;
    return true;
  }

  Future<bool> turnOnBle() async {
    if (!await requestPermissions()) return false;
    if (!await _tryPowerOnBle()) {
      return false;
    }
    return true;
  }

  Future<BluetoothDevice?> scanForNearby({
    required bool Function(BluetoothDevice) onScanResult,
    List<Guid> services = const [],
  }) async {
    if (scanning) await _flutterBlue.stopScan();
    scanning = true;
    notifyListeners();
    BluetoothDevice? ret;
    await for (final r in _flutterBlue.scan(timeout: const Duration(seconds: 20), withServices: services)) {
      if (onScanResult(r.device)) {
        ret = r.device;
        break;
      }
    }
    await _flutterBlue.stopScan();
    scanning = false;
    notifyListeners();
    return ret;
  }

  Future<void> stopScan() {
    scanning = false;
    notifyListeners();
    return _flutterBlue.stopScan();
  }

  Future<BluetoothCharacteristic> discoverAndGetCharacteristic(
    BluetoothDevice d,
    String serviceUuid,
    String charUuid,
  ) async {
    final services = await d.discoverServices();
    final service = services.firstWhere((s) => s.uuid == Guid(serviceUuid));
    final char = service.characteristics.firstWhere((c) => c.uuid == Guid(charUuid));
    return char;
  }
}
