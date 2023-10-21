import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

import 'connect_printer.dart';
import 'niimbot/niimbot_platform_interface/niimbot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Niimbot'),
    );
  }
}

// -----------------------------------------------------------------------------
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .inversePrimary,
          title: Text(title),
        ),
        body: FutureBuilder(
          future: Niimbot().initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            } else {
              return Column(
                children: [
                  TextButton(
                      onPressed: () => checkPermissions(context),
                      child: const Text('Проверить разрешения')),
                  TextButton(
                      onPressed: () => onStartScan(context),
                      child: const Text('StartScan'))
                ],
              );
            }
          },
        ));
  }

  // ---------------------------------------------------------------------------
  Future<void> checkPermissions(BuildContext context) async {
    if (await Permission.bluetoothScan
        .request()
        .isGranted) {
      if (await Permission.bluetooth
          .request()
          .isGranted) {
        if (await Permission.bluetoothConnect
            .request()
            .isGranted) {
          if (await Permission.location
              .request()
              .isGranted) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Все разрешения проверены')));
            }
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  Future<void> onStartScan(BuildContext context) async {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ConnectPrinter())
    );
  }
}
