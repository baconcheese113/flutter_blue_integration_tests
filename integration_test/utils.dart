import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  bool timerDone = false;
  final timer = Timer(timeout, () => throw TimeoutException("Pump until has timed out"));
  while (timerDone != true) {
    await tester.pump();

    final found = tester.any(finder);
    if (found) {
      timerDone = true;
    }
  }
  timer.cancel();
}

// Useful for waiting for mock BLE delays
Future<void> tapAndWaitMs(
  WidgetTester widgetTester,
  Finder finder,
  int milliseconds,
) async {
  await widgetTester.tap(finder);
  await widgetTester.pumpAndSettle();
  await Future.delayed(Duration(milliseconds: milliseconds));
  await widgetTester.pumpAndSettle();
}
