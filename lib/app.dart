import 'package:flutter/material.dart';
import 'package:flutter_blue_integration_tests/ble_provider.dart';
import 'package:flutter_blue_integration_tests/home.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  final BleProvider? bleProvider;
  const App({super.key, this.bleProvider});

  @override
  Widget build(BuildContext context) {
    final provider = bleProvider ?? BleProvider();
    provider.checkPermissions();

    return ChangeNotifierProvider<BleProvider>(
      create: (BuildContext c) => provider,
      child: MaterialApp(
        title: 'Blue Tests',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomePage(),
      ),
    );
  }
}
