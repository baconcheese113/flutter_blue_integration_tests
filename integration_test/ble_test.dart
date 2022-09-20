import 'package:flutter/material.dart';
import 'package:flutter_blue_integration_tests/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'fake_ble_provider.dart';
import 'utils.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Scan test', () {
    testWidgets("Should require permissions before scanning", (widgetTester) async {
      final mockBleProvider = FakeBleProvider();
      runApp(App(bleProvider: mockBleProvider));
      await widgetTester.pumpAndSettle();

      final appBarTextFinder = find.text("Ble devices");
      expect(appBarTextFinder, findsOneWidget);

      final scanIconFinder = find.widgetWithIcon(IconButton, Icons.search);
      expect(scanIconFinder, findsOneWidget);
      await tapAndWaitMs(widgetTester, scanIconFinder, 0);

      final permissionsBtnFinder = find.widgetWithText(TextButton, "Grant BLE Permissions");
      expect(permissionsBtnFinder, findsOneWidget);

      final scanEndIconFinder = find.widgetWithIcon(IconButton, Icons.search_off);
      expect(scanEndIconFinder, findsNothing);
    });

    testWidgets("Should grant permissions on tap", (widgetTester) async {
      final mockBleProvider = FakeBleProvider();
      runApp(App(bleProvider: mockBleProvider));
      await widgetTester.pumpAndSettle();

      final permissionsBtnFinder = find.widgetWithText(TextButton, "Grant BLE Permissions");
      expect(permissionsBtnFinder, findsOneWidget);
      await tapAndWaitMs(widgetTester, permissionsBtnFinder, 0);

      expect(permissionsBtnFinder, findsNothing);
    });

    testWidgets("Should connect/disconnect with found device", (widgetTester) async {
      final mockBleProvider = FakeBleProvider();
      runApp(App(bleProvider: mockBleProvider));

      await widgetTester.pumpAndSettle();
      final permissionsBtnFinder = find.widgetWithText(TextButton, "Grant BLE Permissions");
      expect(permissionsBtnFinder, findsOneWidget);
      await tapAndWaitMs(widgetTester, permissionsBtnFinder, 0);

      final scanIconFinder = find.widgetWithIcon(IconButton, Icons.search);
      expect(scanIconFinder, findsOneWidget);
      await tapAndWaitMs(widgetTester, scanIconFinder, 800);

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
    testWidgets("Should BLE read/write/notify with found device", (widgetTester) async {
      final mockBleProvider = FakeBleProvider();
      runApp(App(bleProvider: mockBleProvider));
      await widgetTester.pumpAndSettle();

      final permissionsBtnFinder = find.widgetWithText(TextButton, "Grant BLE Permissions");
      expect(permissionsBtnFinder, findsOneWidget);
      await tapAndWaitMs(widgetTester, permissionsBtnFinder, 0);

      final scanIconFinder = find.widgetWithIcon(IconButton, Icons.search);
      expect(scanIconFinder, findsOneWidget);
      await widgetTester.tap(scanIconFinder);

      final connectBtnFinder = find.widgetWithText(TextButton, "Connect");
      await pumpUntilFound(widgetTester, connectBtnFinder);
      expect(connectBtnFinder, findsOneWidget);
      await widgetTester.tap(connectBtnFinder);

      final scanEndIconFinder = find.widgetWithIcon(IconButton, Icons.search_off);
      expect(scanEndIconFinder, findsOneWidget);

      final readBtnFinder = find.widgetWithText(TextButton, "Read");
      await pumpUntilFound(widgetTester, readBtnFinder);
      expect(readBtnFinder, findsOneWidget);
      await tapAndWaitMs(widgetTester, readBtnFinder, 800);
      final textReadFinder = find.byKey(const ValueKey("text.read"));
      expect(textReadFinder, findsOneWidget);
      var text = textReadFinder.evaluate().single.widget as Text;
      expect(text.data, "FirstRead");

      final textFieldWriteFinder = find.byKey(const ValueKey("textField.write"));
      expect(textFieldWriteFinder, findsOneWidget);
      await widgetTester.enterText(textFieldWriteFinder, "FirstWrite");
      final writeBtnFinder = find.widgetWithText(TextButton, "Write");
      expect(writeBtnFinder, findsOneWidget);
      await tapAndWaitMs(widgetTester, writeBtnFinder, 800);

      await tapAndWaitMs(widgetTester, readBtnFinder, 800);
      text = textReadFinder.evaluate().single.widget as Text;
      expect(text.data, "SecondRead");

      final enableNotifyBtnFinder = find.byKey(const ValueKey("button.notify"));
      expect(enableNotifyBtnFinder, findsOneWidget);
      await tapAndWaitMs(widgetTester, enableNotifyBtnFinder, 800);

      await widgetTester.enterText(textFieldWriteFinder, "SecondWrite");
      await tapAndWaitMs(widgetTester, writeBtnFinder, 800);
      text = textReadFinder.evaluate().single.widget as Text;
      expect(text.data, "ThirdRead");

      final disconnectBtnFinder = find.widgetWithText(TextButton, "Disconnect");
      expect(disconnectBtnFinder, findsOneWidget);
      await tapAndWaitMs(widgetTester, disconnectBtnFinder, 0);

      expect(connectBtnFinder, findsOneWidget);
    });
  });
}
