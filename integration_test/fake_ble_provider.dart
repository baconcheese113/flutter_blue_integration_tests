import 'package:flutter_blue_integration_tests/ble_provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'fake_flutter_blue.dart';

class FakeBleProvider extends BleProvider {
  @override
  Future<void> checkPermissions() {
    return Future(() => false);
  }

  @override
  Future<bool> requestPermissions() async {
    hasPermissions = true;
    notifyListeners();
    return Future(() => true);
  }

  @override
  Future<BluetoothDevice?> scanForNearby(
      {required bool Function(BluetoothDevice p1)? onScanResult, List<Guid>? services = const []}) async {
    scanning = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    final mockBluetoothDevice = FakeBluetoothDevice.fromId("TE:ST:AD:DR:ES");
    onScanResult!(mockBluetoothDevice);
    await Future.delayed(const Duration(seconds: 1));
    scanning = false;
    notifyListeners();
    return mockBluetoothDevice;
  }

  @override
  Future<void> stopScan() async {
    await Future.delayed(const Duration(milliseconds: 200));
    scanning = false;
    notifyListeners();
  }
}
