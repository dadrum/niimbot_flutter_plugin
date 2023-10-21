import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

import 'niimbot/models/print_process_event.dart';
import 'niimbot/models/printer_state_event.dart';
import 'niimbot/niimbot_platform_interface/niimbot.dart';

class PrinterWork extends StatefulWidget {
  const PrinterWork({super.key});

  @override
  State<PrinterWork> createState() => _PrinterWorkState();
}

class _PrinterWorkState extends State<PrinterWork> {
  late StreamSubscription<NiimbotPrinterStateEvent> _printerEventsSubscription;
  late StreamSubscription<NiimbotPrintProcessEvent> _printProcessSubscription;

  late final Niimbot _api;

  List<String> jsonList = [];
  List<String> infoList = [];

  bool _isCancel = false;

  bool _isError = false;

  int pageCount = 1;

  int quantity = 1;

  // Увеличение печати (разрешение)
  final printMultiple = 8.0;

  // ---------------------------------------------------------------------------
  @override
  void initState() {
    _api = Niimbot();
    _printerEventsSubscription = _api.printerCallbackStream
        .listen((event) => onPrinterEventReceived(context, event));
    _printProcessSubscription = _api.printProcessCallbackStream
        .listen((event) => onPrintProcessEventReceived(context, event));
    super.initState();
  }

  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    _printerEventsSubscription.cancel();
    _printProcessSubscription.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Печать'),
      ),
      body: Column(
        children: [
          TextButton(onPressed: onCancelTapped, child: const Text('cancel')),
          TextButton(onPressed: onStartPrintTapped, child: const Text('print')),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Future<void> onCancelTapped() async {
    await _api.cancelJob();
  }

  // ---------------------------------------------------------------------------
  Future<void> onStartPrintTapped() async {
    jsonList = [];
    infoList = [];

    await generateMultiPagePrintData(0, 1);

    final totalQuantity = pageCount * quantity;
    await _api.setTotalQuantityOfPrints(totalQuantity);
    await _api.startPrintJob(density: 3, paperType: 1, printMode: 1);
    await _api.commitData(printDataList: jsonList, printerInfoList: infoList);
  }

  // ---------------------------------------------------------------------------
  Future<void> onPrinterEventReceived(
    BuildContext context,
    NiimbotPrinterStateEvent event,
  ) async =>
      switch (event) {
        NimmbotEventTryToCreateBound _ => null,
        NimmbotEventBoundFailed _ => null,
        NimmbotEventTryToOpenPrinter _ => null,
        NimmbotConnectResult _ => null,
        NimmbotEventOnDisconnected _ => null,
        NimmbotEventOnConnected _ => null,
        NimmbotEventOnElectricityChanged _ => null,
        NimmbotEventOnCoverStatus _ => null,
        NimmbotEventOnPaperStatus _ => null,
        NimmbotEventOnRfidReadStatus _ => null,
        NimmbotEventOnPrinterIsFree _ => null,
        NimmbotEventOnHeartDisConnect _ => null,
        NimmbotEventOnFirmErrors _ => null,
      };

  // ---------------------------------------------------------------------------
  Future<void> onPrintProcessEventReceived(
    BuildContext context,
    NiimbotPrintProcessEvent event,
  ) async =>
      switch (event) {
        final NimmbotEventPrintOnProgress e => _printOnProgress(e),
        final NimmbotEventPrintOnError e => _printOnError(e),
        final NimmbotEventPrintOnCancelJob e => _printOnCancel(e),
        final NimmbotEventPrintOnBufferFree e => _printOnBufferFree(e),
        NiimbotPrintProcessEventFactory _ => null,
      };

  // ---------------------------------------------------------------------------
  Future<void> _printOnProgress(NimmbotEventPrintOnProgress e) async {
    if (e.pageIndex == pageCount && e.quantityIndex == quantity) {
      // завершение печати
      if (await _api.endJob()) {
        // печать успешно завершена
        _notifyToUser('печать успешно завершена');
      } else {
        _notifyToUser('ошибка при завершении печати');
      }
      _notifyToUser('печать завершена');
    }
  }

  // ---------------------------------------------------------------------------
  Future<void> _printOnBufferFree(NimmbotEventPrintOnBufferFree e) async {
    if (_isError || _isCancel) {
      return;
    }

    if (e.pageIndex > pageCount) {
      return;
    }

    // print('Test: Sent page data: ' +
    //     e.pageIndex.toString() +
    //     ', Buffer size: ' +
    //     e.bufferSize.toString());
    // print('Test: Generated sequence: ' + generatedPrintDataPageCount[0]);
    // print('Test: Total page count: ' + pageCount.toString());
    // print(
    //     'Test - Idle data callback - Data generation check - Total page count: ' +
    //         pageCount.toString() +
    //         ', Generated page count: ' +
    //         generatedPrintDataPageCount[0] +
    //         ', Idle callback data length: ' +
    //         e.bufferSize.toString());
    //
    // //Generate data only if the number of generated pages is less than the total number of pages
    // if (generatedPrintDataPageCount[0] < pageCount) {
    //   //Length of data to be generated
    //   final int commitDataLength =
    //       Math.min((pageCount - generatedPrintDataPageCount[0]), bufferSize);
    //   generateMultiPagePrintData(generatedPrintDataPageCount[0],
    //       generatedPrintDataPageCount[0] + commitDataLength);
    //
    //   PrintUtil.getInstance().commitData(
    //       jsonList.subList(generatedPrintDataPageCount[0],
    //           generatedPrintDataPageCount[0] + commitDataLength),
    //       infoList.subList(generatedPrintDataPageCount[0],
    //           generatedPrintDataPageCount[0] + commitDataLength));
    //
    //   generatedPrintDataPageCount[0] += commitDataLength;
    // }

    // if (generatedPrintDataPageCount[0] < pageCount) {
    //   if ((pageCount - generatedPrintDataPageCount[0]) < e.bufferSize) {
    // //
    // generateMultiPagePrintData(generatedPrintDataPageCount[0], pageCount);
    // //
    // _api.commitData(
    //   printDataList:
    //       jsonList.subList(generatedPrintDataPageCount[0], pageCount),
    //   printerInfoList:
    //       infoList.subList(generatedPrintDataPageCount[0], pageCount),
    // );
    //
    // generatedPrintDataPageCount[0] += pageCount;
    // } else {
    // generateMultiPagePrintData(generatedPrintDataPageCount[0],
    //     generatedPrintDataPageCount[0] + e.bufferSize);
    //
    // _api.commitData(
    //     printDataList: jsonList.subList(generatedPrintDataPageCount[0],
    //         generatedPrintDataPageCount[0] + e.bufferSize),
    //     printerInfoList: infoList.subList(generatedPrintDataPageCount[0],
    //         generatedPrintDataPageCount[0] + e.bufferSize));
    // generatedPrintDataPageCount[0] += e.bufferSize;
    // }
    // }
  }

  Future<void> generateMultiPagePrintData(int index, int cycleIndex) async {
    while (index < cycleIndex) {
      const double width = 22.0;
      const double height = 14.0;
      const int orientation = 90;

      /*
     * Set canvas size
     *
     * @param width Canvas width
     * @param height Canvas height
     * @param orientation Canvas rotation angle
     * @param fontDir Font path not available for now, use ""
     *
     */
      await _api.drawEmptyLabel(
        width: width,
        height: height,
        rotate: orientation,
        fontDir: '',
      );

      await _api.drawLabelText(
          x: 10.5,
          y: 2,
          width: 12,
          height: 3,
          value: 'Title',
          fontFamily: '',
          fontSize: 2,
          rotate: 0,
          textAlignHorizontal: 0,
          textAlignVertical: 0,
          lineModel: 4,
          letterSpace: 0,
          lineSpace: 0,
          mFontStyles: [true, false, false, false]);

      await _api.drawLabelText(
          x: 10.5,
          y: 5.5,
          width: 11.5,
          height: 3,
          value: 'text',
          fontFamily: '',
          fontSize: 2,
          rotate: 0,
          textAlignHorizontal: 1,
          textAlignVertical: 0,
          lineModel: 2,
          letterSpace: 0,
          lineSpace: 0,
          mFontStyles: [false, false, false, false]);

      await _api.drawLabelText(
          x: 10.5,
          y: 8.5,
          width: 11.5,
          height: 3,
          value: '1234',
          fontFamily: '',
          fontSize: 2.5,
          rotate: 0,
          textAlignHorizontal: 1,
          textAlignVertical: 0,
          lineModel: 2,
          letterSpace: 0,
          lineSpace: 0,
          mFontStyles: [true, false, false, false]);


      // ПОСТОЯННО ПЕЧАТАЕТ 123456789
      // _api.drawLabelQrCode(
      //   x: 1.5,
      //   y: 2,
      //   width: 9,
      //   height: 9,
      //   codeType: 34,
      //   value: 'abc1234',
      //   rotate: 0,
      // );

      // draw QR code
      final qrCode = QrCode(1, QrErrorCorrectLevel.H)..addData('8721');
      final qrImage = QrImage(qrCode);
      const qrLeft = 1.0;
      const qrTop = 2.0;
      const qrWidth = 9.0;
      final qrSquareSize = qrWidth / qrImage.moduleCount;
      for (var x = 0; x < qrImage.moduleCount; x++) {
        for (var y = 0; y < qrImage.moduleCount; y++) {
          if (qrImage.isDark(y, x)) {
            await _api.drawLabelGraph(
              x: qrLeft + x * qrSquareSize,
              y: qrTop + y * qrSquareSize,
              width: qrSquareSize + 0.008,
              height: qrSquareSize + 0.01,
              graphType: 3,
              rotate: 0,
              cornerRadius: 0,
              lineWidth: 0.2,
              lineType: 0.2,
              dashWidth: [],
            );
          }
        }
      }

      final jsonByte = await _api.generateLabelJson();
      final jsonStr = String.fromCharCodes(jsonByte);

      jsonList.add(jsonStr);
      //
      final jsonInfo = '{  ' +
          '\"printerImageProcessingInfo\": ' +
          '{    ' +
          '\"orientation\":' +
          orientation.toString() +
          ',' +
          '   \"margin\": [      0,      0,      0,      0    ], ' +
          '   \"printQuantity\": ' +
          quantity.toString() +
          ',  ' +
          '  \"horizontalOffset\": 0,  ' +
          '  \"verticalOffset\": 0,  ' +
          '  \"width\":' +
          width.toString() +
          ',' +
          '   \"height\":' +
          height.toString() +
          ',' +
          '\"printMultiple\":' +
          printMultiple.toString() +
          ',' +
          '  \"epc\": \"\"  }}';
      infoList.add(jsonInfo);

      index++;
    }
  }

  // ---------------------------------------------------------------------------
  Future<void> _printOnError(NimmbotEventPrintOnError e) async {
    _isError = true;
    _notifyToUser(
        'Ошибка при печати: code=${e.errorCode}, state=${e.printState}');
  }

  // ---------------------------------------------------------------------------
  Future<void> _printOnCancel(NimmbotEventPrintOnCancelJob e) async {
    _isCancel = true;
    _notifyToUser('Отмена задачи');
  }

  // ---------------------------------------------------------------------------
  void _notifyToUser(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
