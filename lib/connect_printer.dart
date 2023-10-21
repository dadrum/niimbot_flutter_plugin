import 'dart:async';

import 'package:flutter/material.dart';

import 'niimbot/models/bt_printer_info.dart';
import 'niimbot/models/connect_result_type.dart';
import 'niimbot/models/printer_state_event.dart';
import 'niimbot/niimbot_platform_interface/niimbot.dart';
import 'print_work.dart';

class ConnectPrinter extends StatefulWidget {
  const ConnectPrinter({super.key});

  @override
  State<ConnectPrinter> createState() => _ConnectPrinterState();
}

class _ConnectPrinterState extends State<ConnectPrinter> {
  List<BtDeviceInfo> btDevices = [];

  late StreamSubscription<NiimbotPrinterStateEvent> _eventsSubscriptions;

  String? printerAddress;

  @override
  void initState() {
    _eventsSubscriptions = Niimbot().printerCallbackStream.listen((event) {
      if (event is NimmbotConnectResult) {
        if (event.status == NimmbotConnectResultType.successfullyConnected) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const PrinterWork(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(event.toString())));
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _eventsSubscriptions.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Поиск принтеров'),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: onIsConnected, child: const Text('isConnected')),
          TextButton(onPressed: onClose, child: const Text('close')),
          TextButton(onPressed: onStartScan, child: const Text('Начать поиск')),
          const Divider(),
          Expanded(
              child: ListView.builder(
                  itemCount: btDevices.length,
                  itemBuilder: (context, index) {
                    final item = btDevices[index];
                    return TextButton(
                        onPressed: () => onPrinterTapped(item),
                        child: Text(item.name ??
                            (item.address ?? (item.deviceInfo ?? 'No name'))));
                  }))
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Future<void> onClose() async {
    Niimbot().close();
  }

  // ---------------------------------------------------------------------------
  Future<void> onIsConnected() async {
    final res = await Niimbot().isConnected();
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.toString())));
    }
  }

  // ---------------------------------------------------------------------------
  Future<void> onPrinterTapped(BtDeviceInfo btDevice) async {
    printerAddress = btDevice.address!;
    Niimbot().connectToPrinter(btDevice.address!);
  }

  // ---------------------------------------------------------------------------
  Future<void> onStartScan() async {
    setState(() {
      btDevices = [];
    });

    Niimbot().newBtDeviceStream.listen((event) {
      setState(() {
        btDevices.add(event);
      });
    });
    Niimbot().scanPrinters();
  }
}
