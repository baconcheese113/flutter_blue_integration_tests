import 'package:flutter/material.dart';
import 'package:flutter_blue_integration_tests/app.dart';
import 'package:flutter_blue_integration_tests/ble_provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'utils.dart';

class FakeBluetoothDevice extends BluetoothDevice {
  FakeBluetoothDevice.fromId(id) : super.fromId(id);

  @override
  Future<void> connect({Duration? timeout, bool autoConnect = true}) async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future disconnect() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

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
}

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Scan test', () {
    testWidgets("Should require permissions before scanning", (widgetTester) async {
      final mockBleProvider = FakeBleProvider();
      runApp(App(bleProvider: mockBleProvider));

      final appBarTextFinder = find.text("Ble devices");
      await pumpUntilFound(widgetTester, appBarTextFinder);
      expect(appBarTextFinder, findsOneWidget);

      final scanIconFinder = find.widgetWithIcon(IconButton, Icons.search);
      expect(scanIconFinder, findsOneWidget);
      await widgetTester.tap(scanIconFinder);

      final permissionsBtnFinder = find.widgetWithText(TextButton, "Grant BLE Permissions");
      expect(permissionsBtnFinder, findsOneWidget);

      final scanEndIconFinder = find.widgetWithIcon(IconButton, Icons.search_off);
      await widgetTester.pumpAndSettle();
      expect(scanEndIconFinder, findsNothing);
    });

    testWidgets("Should grant permissions on tap", (widgetTester) async {
      final mockBleProvider = FakeBleProvider();
      runApp(App(bleProvider: mockBleProvider));

      await widgetTester.pumpAndSettle();
      final permissionsBtnFinder = find.widgetWithText(TextButton, "Grant BLE Permissions");
      expect(permissionsBtnFinder, findsOneWidget);
      await widgetTester.tap(permissionsBtnFinder);
      await widgetTester.pumpAndSettle();

      expect(permissionsBtnFinder, findsNothing);
    });

    testWidgets("Should connect to found device", (widgetTester) async {
      final mockBleProvider = FakeBleProvider();
      runApp(App(bleProvider: mockBleProvider));

      await widgetTester.pumpAndSettle();
      final permissionsBtnFinder = find.widgetWithText(TextButton, "Grant BLE Permissions");
      expect(permissionsBtnFinder, findsOneWidget);
      await widgetTester.tap(permissionsBtnFinder);
      await widgetTester.pumpAndSettle();

      final scanIconFinder = find.widgetWithIcon(IconButton, Icons.search);
      expect(scanIconFinder, findsOneWidget);
      await widgetTester.tap(scanIconFinder);
      await widgetTester.pumpAndSettle();

      final connectBtnFinder = find.widgetWithText(TextButton, "Connect");
      await pumpUntilFound(widgetTester, connectBtnFinder);
      expect(connectBtnFinder, findsOneWidget);
      await widgetTester.tap(connectBtnFinder);

      final scanEndIconFinder = find.widgetWithIcon(IconButton, Icons.search_off);
      expect(scanEndIconFinder, findsOneWidget);

      final disconnectBtnFinder = find.widgetWithText(TextButton, "Disconnect");
      await pumpUntilFound(widgetTester, disconnectBtnFinder);
      expect(disconnectBtnFinder, findsOneWidget);
      await widgetTester.tap(disconnectBtnFinder);
      await widgetTester.pumpAndSettle();

      expect(connectBtnFinder, findsOneWidget);
    });
  });
}
