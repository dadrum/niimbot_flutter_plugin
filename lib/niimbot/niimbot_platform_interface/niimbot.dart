import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/handbook.dart';
import '../models/bt_printer_info.dart';
import '../models/device_guide.dart';
import '../models/device_module.dart';
import '../models/print_process_event.dart';
import '../models/printer_state_event.dart';
import 'niimbot_platform_interface.dart';

/// An implementation of [NiimbotPlatform] that uses method channels.
class Niimbot extends NiimbotPlatform {
  factory Niimbot() {
    return _instance;
  }

  Niimbot._internal();

  static final Niimbot _instance = Niimbot._internal();

  Iterable<DeviceModule>? _supportedDevicesConfiguration;
  Iterable<DeviceGuide>? _supportedDevicesGuides;

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('niimbot');

  final EventChannel _onBtDeviceFoundChannel =
      const EventChannel('niimbot_on_bt_device_found_channel');

  final EventChannel _onPrinterCallbackChannel =
      const EventChannel('niimbot_on_printer_callback_channel');

  final EventChannel _onPrintProcessCallbackChannel =
      const EventChannel('niimbot_on_print_process_callback_channel');

  // ---------------------------------------------------------------------------
  @override
  Future<void> scanPrinters() async {
    // final supportedModels = _supportedDevicesConfiguration.map((e) => e.modelName);
    await methodChannel.invokeMethod<String>('scanPrinters');
  }

  // ---------------------------------------------------------------------------
  /// статус подключения к принтеру
  /// 0 = подключен
  /// -1 = не подключен
  /// -2 = занят (только B21)
  /// -3 = не поддерживается
  @override
  Future<int> isConnected() async {
    return (await methodChannel.invokeMethod<int>('isConnected'))!;
  }

  // ---------------------------------------------------------------------------
  @override
  Future<void> close() async {
    await methodChannel.invokeMethod<void>('close');
  }

  // ---------------------------------------------------------------------------
  @override
  Future<void> initialize() async {
    // инициализируем натив
    await methodChannel.invokeMethod<void>('initialize');
  }

  // ---------------------------------------------------------------------------
  @override
  Future<Iterable<DeviceModule>> getDevicesConfigurations() async {
    if (_supportedDevicesConfiguration != null) {
      return _supportedDevicesConfiguration!;
    } else {
      // парсим библиотеку принтеров
      final jsonData = (await compute(_parseHandbook, Handbook.printerModels))
          as List<dynamic>;
      _supportedDevicesConfiguration =
          jsonData.map((e) => DeviceModule.fromJson(e as Map<String, dynamic>));
      return _supportedDevicesConfiguration!;
    }
  }

  // ---------------------------------------------------------------------------
  @override
  Future<Iterable<DeviceGuide>> getDevicesGuides() async {
    if (_supportedDevicesGuides != null) {
      return _supportedDevicesGuides!;
    } else {
      // парсим библиотеку принтеров
      final jsonData = (await compute(_parseHandbook, Handbook.printerModels))
          as List<dynamic>;
      _supportedDevicesGuides =
          jsonData.map((e) => DeviceGuide.fromJson(e as Map<String, dynamic>));
      return _supportedDevicesGuides!;
    }
  }

  // ---------------------------------------------------------------------------
  @override
  Future<void> connectToPrinter(String printerAddress) async {
    await methodChannel
        .invokeMethod<void>('connectToPrinter', <String, dynamic>{
      'deviceAddress': printerAddress,
    });
  }

  // ---------------------------------------------------------------------------
  @override
  Stream<BtDeviceInfo> get newBtDeviceStream {
    return _onBtDeviceFoundChannel
        .receiveBroadcastStream()
        .map((e) => BtDeviceInfo(
              bondState: e['bondState'],
              address: e['address'] as String?,
              deviceInfo: e['deviceInfo'] as String?,
              name: e['name'] as String?,
              uuids: e['uuids'] as String?,
              type: e['type'] as int?,
            ));
  }

  // ---------------------------------------------------------------------------
  @override
  Stream<NiimbotPrinterStateEvent> get printerCallbackStream {
    return _onPrinterCallbackChannel
        .receiveBroadcastStream()
        .map((e) => NiimbotPrinterStateEventFactory.fromEventName(
              e['eventName'] as String,
              e['v1'] as dynamic,
            ));
  }

  // ---------------------------------------------------------------------------
  @override
  Stream<NiimbotPrintProcessEvent> get printProcessCallbackStream {
    return _onPrintProcessCallbackChannel
        .receiveBroadcastStream()
        .map((e) => NiimbotPrintProcessEventFactory.fromEventName(
              e['eventName'] as String,
              e['v1'] as dynamic,
              e['v2'] as dynamic,
              e['v3'] as dynamic,
            ));
  }

  // ---------------------------------------------------------------------------
  /// запустить задание на печать
  @override
  Future<void> startPrintJob({
    /// плотность
    ///    D11, D101, D110 = [1..3], по-умолчанию 2
    ///    B3S, B203, B1, B16 = [1..5], по-умолчанию 3
    ///  ? B16 = [1..3], по-умолчанию 2
    ///    B18 = [1..3], по-умолчанию 2
    ///    B50, B11, B50W, B32, Z401 = [1..15], по-умолчанию 8
    required int density,

    /// тип бумаги
    ///    1 = бумага с пробелами
    ///    2 = бумага с черными метками
    ///    3 = непрерывная бумага
    ///    4 = бумага с фиксированными отверстиями
    ///    5 = прозрачная бумага
    required int paperType,

    /// режим печати
    ///    1 = режим термопечати
    ///        D11, D101, D110D B3S, B203, B1, B16, B11
    ///
    ///    2 = режим термопереноса
    ///        B18, B50, B11 B50W, B32, Z401
    required int printMode,
  }) async {
    await methodChannel.invokeMethod<void>('startPrintJob', <String, dynamic>{
      'density': density,
      'paperType': paperType,
      'printMode': printMode,
    });
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  // ---------------------------------------------------------------------------
  /// отправка данных в виде JSON
  @override
  Future<void> commitData({
    /// данные для печати
    required List<String> printDataList,

    /// список информации о принтере
    required List<String> printerInfoList,
  }) async {
    await methodChannel.invokeMethod<void>('commitData', <String, dynamic>{
      'printDataList': printDataList,
      'printerInfoList': printerInfoList,
    });
  }

  // ---------------------------------------------------------------------------
  /// отправка растрового изображения
  @override
  Future<void> commitImageData({
    /// Угол поворота, по умолчанию — 0, без вращения. Поддерживаемые углы поворота 0, 90, 180, 270.
    required int orientation,
    // TODO уточнить тип данных
    /// ширина изображения (пиксели) = ширина этикетки (мм) * увеличение
    /// высота изображения (пиксели) = высота этикетки (мм) * увеличение
    /// B32/Z401/T8 увеличение = 11,81
    /// остальные = 8
    required Object printBitmap,

    /// ширина этикетки (мм)
    required int pageWidth,

    /// высота этикетки (мм)
    required int pageHeight,

    /// количество
    required int quantity,

    /// отступ сверху
    required int marginTop,

    /// отступ слева
    required int marginLeft,

    /// отступ снизу
    required int marginBottom,

    /// отступ справа
    required int marginRight,

    /// данные о записи RFID-метки (только для тех моделей, которые поддерживают)
    /// можно отправлять пустую строку
    required String rfid,
  }) async {
    await methodChannel.invokeMethod<void>('commitImageData', <String, dynamic>{
      'orientation': orientation,
      // TODO уточнить тип данных
      'printBitmap': printBitmap,
      'pageWidth': pageWidth,
      'pageHeight': pageHeight,
      'quantity': quantity,
      'marginTop': marginTop,
      'marginLeft': marginLeft,
      'marginBottom': marginBottom,
      'marginRight': marginRight,
      'rfid': rfid,
    });
  }

  // ---------------------------------------------------------------------------
  /// метод, вызываемый после печати последней страницы, чтобы отметить
  /// завершенность предыдущего задания перед запуском startJob
  @override
  Future<bool> endJob() async {
    return (await methodChannel.invokeMethod<bool>('endJob')) ?? false;
  }

  // ---------------------------------------------------------------------------
  /// метод для отмены текущего задания
  @override
  Future<void> cancelJob() => methodChannel.invokeMethod<void>('cancelJob');

  // ---------------------------------------------------------------------------
  /// инициализация шрифта
  @override
  Future<void> initImageProcessingDefault({
    /// путь к шрифту
    required String fontFamilyPath,

    /// шрифт по-умолчанию
    required String defaultFamilyPath,
  }) async {
    await methodChannel
        .invokeMethod<void>('initImageProcessingDefault', <String, dynamic>{
      'fontFamilyPath': fontFamilyPath,
      'defaultFamilyPath': defaultFamilyPath,
    });
  }

  // ---------------------------------------------------------------------------
  /// инициализация пустого артборда
  @override
  Future<void> drawEmptyLabel({
    /// ширина (мм)
    required double width,

    /// высота (мм)
    required double height,

    /// угол поворота 0/90/180/270
    required int rotate,

    /// путь к шрифту (в настоящее время не поддерживается). По-умолчанию - пустая строка
    required String fontDir,
  }) async {
    await methodChannel.invokeMethod<void>('drawEmptyLabel', <String, dynamic>{
      'width': width,
      'height': height,
      'rotate': rotate,
      'fontDir': fontDir,
    });
  }

  // ---------------------------------------------------------------------------
  /// инициализация артборда с текстом
  @override
  Future<void> drawLabelText({
    /// положение по Х (мм)
    required double x,

    /// положение по Y (мм)
    required double y,

    /// Ширина текстового поля, мм.
    required double width,

    /// Высота текстового поля, мм
    required double height,

    /// содержание
    required String value,

    /// шрифт. Если пустая строка, то используется шрифт по-умолчанию
    required String fontFamily,

    /// Размер шрифта, мм.
    required double fontSize,

    /// Угол поворота, по умолчанию — 0, без вращения. Поддерживаемые углы поворота 0, 90, 180, 270.
    required double rotate,

    /// Выравнивание по горизонтали: 0: Выравнивание по левому краю 1: Выравнивание по центру 2: Выравнивание по правому краю
    required int textAlignHorizontal,

    /// Выравнивание по вертикали: 0: Выравнивание по верху 1: Центрирование по вертикали 2: Выравнивание по низу
    required int textAlignVertical,

    /// 1: Фиксированная ширина и высота, адаптивный размер содержимого (размер шрифта / межсимвольный интервал / межстрочный интервал масштабируется по масштабу)
    /// 2: Фиксированная ширина, адаптивная высота
    /// 3: фиксированные ширина и высота, добавляются после превышения содержимого...
    /// 4: Фиксированная ширина и высота, прямая вырезка за пределы содержимого
    /// 6: Фиксированная ширина и высота, автоматическое сокращение, когда содержимое превышает заданные ширину и высоту (размер шрифта / межсимвольный интервал / межстрочный интервал масштабируются в соответствии с масштабом)
    required int lineModel,

    /// Стандартный интервал между буквами в мм
    required double letterSpace,

    /// Межстрочный интервал (временный интервал), единица измерения мм
    required double lineSpace,

    /// стиль шрифта [полужирный, курсив, подчеркивание, удалить подчеркивание (зарезервировано)]
    required List<bool> mFontStyles,
  }) async {
    await methodChannel.invokeMethod<void>('drawLabelText', <String, dynamic>{
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'value': value,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'rotate': rotate,
      'textAlignHorizontal': textAlignHorizontal,
      'textAlignVertical': textAlignVertical,
      'lineModel': lineModel,
      'letterSpace': letterSpace,
      'lineSpace': lineSpace,
      'mFontStyles': mFontStyles,
    });
  }

  // ---------------------------------------------------------------------------
  /// рисование линейного кода
  @override
  Future<void> drawLabelBarCode({
    /// положение по Х (мм)
    required double x,

    /// положение по Y (мм)
    required double y,

    /// Ширина штрих-кода, мм.
    required double width,

    /// Высота штрих-кода, мм
    required double height,

    /// Тип штрих-кода. Тип по умолчанию 20
    /// 20:CODE128
    /// 21:UPC-A
    /// 22:UPC-E
    /// 23:EAN8
    /// 24:EAN13
    /// 25:CODE93
    /// 26:CODE39
    /// 27:CODEBAR
    /// 28:ITF25
    required int codeType,

    /// содержимое штрих-кода
    required String value,

    /// Размер шрифта, мм. По умолчанию — 4 мм.
    required int fontSize,

    /// Угол поворота артборда, по умолчанию — 0, без вращения. Поддерживаемые углы поворота 0, 90, 180, 270.
    required double rotate,

    /// Высота текста. Высота по умолчанию составляет 4 мм.
    required int textHeight,

    /// Положение текста штрих-кода.
    /// По умолчанию — 0.
    /// * 0: отображается ниже
    /// * 1: отображается вверху
    /// * 2: не отображается
    required int textPosition,
  }) async {
    await methodChannel.invokeMethod<void>('drawLabelBarCode', <String, dynamic>{
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'value': value,
      'fontSize': fontSize,
      'rotate': rotate,
      'codeType': codeType,
      'textHeight': textHeight,
      'textPosition': textPosition,
    });
  }

  // ---------------------------------------------------------------------------
  @override
  Future<void> drawLabelQrCode({
    /// положение по Х (мм)
    required double x,

    /// положение по Y (мм)
    required double y,

    /// Ширина штрих-кода, мм.
    required double width,

    /// Высота штрих-кода, мм
    required double height,

    /// содержимое штрих-кода
    required String value,

    /// Угол поворота артборда, по умолчанию — 0, без вращения. Поддерживаемые углы поворота 0, 90, 180, 270.
    required int rotate,

    /// Тип QR-кода, тип по умолчанию 31.
    /// 31:QR_CODE
    /// 32:PDF417
    /// 33:DATA_MATRIX
    /// 34:AZTEC
    required int codeType,
  }) async {
    await methodChannel.invokeMethod<void>('drawLabelQrCode', <String, dynamic>{
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'value': value,
      'rotate': rotate,
      'codeType': codeType,
    });
  }

  // ---------------------------------------------------------------------------
  /// рисование фигур
  @override
  Future<void> drawLabelGraph({
    /// положение по Х (мм)
    required double x,

    /// положение по Y (мм)
    required double y,

    /// Ширина текстового поля, мм.
    required double width,

    /// Высота текстового поля, мм
    required double height,

    /// Тип изображения, тип по умолчанию — 1. 1: Круг, 2: Эллипс, 3: Прямоугольник, 4: Прямоугольник со скругленными углами.
    required int graphType,

    /// Угол поворота, по умолчанию — 0, без вращения. Поддерживаемые углы поворота 0, 90, 180, 270.
    required int rotate,

    /// Угловой радиус, ед. мм
    required double cornerRadius,

    /// Ширина линии
    required double lineWidth,

    /// Тип линии, тип по умолчанию — 1. 1: сплошная линия, 2: пунктирная линия.
    required double lineType,

    /// Параметры пунктирных линий
    required List<double> dashWidth,
  }) async {
    await methodChannel.invokeMethod<void>('drawLabelGraph', <String, dynamic>{
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'graphType': graphType,
      'rotate': rotate,
      'cornerRadius': cornerRadius,
      'lineWidth': lineWidth,
      'lineType': lineType,
      'dashWidth': dashWidth,
    });
  }

  // ---------------------------------------------------------------------------
  /// рисование изображений
  @override
  Future<void> drawLabelImage({
    /// данные изображения в формате base64
    required String imageData,

    /// положение по Х (мм)
    required double x,

    /// положение по Y (мм)
    required double y,

    /// Ширина изображения, мм.
    required double width,

    /// Высота изображения, мм
    required double height,

    /// Угол поворота, по умолчанию — 0, без вращения. Поддерживаемые углы поворота 0, 90, 180, 270.
    required int rotate,

    /// тип алгоритма обработки
    required int imageProcessingType,

    /// порог обработки изображения, по-умолчанию 127
    required double imageProcessingValue,
  }) async {
    await methodChannel.invokeMethod<void>('drawLabelImage', <String, dynamic>{
      'imageData': imageData,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotate': rotate,
      'imageProcessingType': imageProcessingType,
      'imageProcessingValue': imageProcessingValue,
    });
  }

  // ---------------------------------------------------------------------------
  /// рисование линий
  @override
  Future<void> drawLabelLine({
    /// положение по Х (мм)
    required double x,

    /// положение по Y (мм)
    required double y,

    /// Ширина текстового поля, мм.
    required double width,

    /// Высота текстового поля, мм
    required double height,

    /// Угол поворота, по умолчанию — 0, без вращения. Поддерживаемые углы поворота 0, 90, 180, 270.
    required int rotate,

    /// Тип линии, тип по умолчанию — 1. 1: сплошная линия, 2: пунктирная линия.
    required double lineType,

    /// Параметры пунктирных линий
    required List<double> dashWidth,
  }) async {
    await methodChannel.invokeMethod<void>('drawLabelLine', <String, dynamic>{
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotate': rotate,
      'lineType': lineType,
      'dashWidth': dashWidth,
    });
  }

  // ---------------------------------------------------------------------------
  /// выгрузка изображения в формате JSON
  // TODO уточнить тип данных
  @override
  Future<dynamic> generateLabelJson() async {
    return (await methodChannel.invokeMethod<dynamic>('generateLabelJson'))!;
  }

  // ---------------------------------------------------------------------------
  @override
  Future<int> setPrintLanguage(int printLanguage) async {
    return (await methodChannel.invokeMethod<int>(
      'setPrintLanguage',
      <String, dynamic>{
        'printLanguage': printLanguage,
      },
    )) as int;
  }

  @override
  Future<int> setPrinterDensity(int printerDensity) async {
    return (await methodChannel.invokeMethod<int>(
      'setPrinterDensity',
      <String, dynamic>{
        'printerDensity': printerDensity,
      },
    )) as int;
  }

  @override
  Future<int> setPrinterSpeed(int printerSpeed) async {
    return (await methodChannel.invokeMethod<int>(
      'setPrinterSpeed',
      <String, dynamic>{
        'printerSpeed': printerSpeed,
      },
    )) as int;
  }

  @override
  Future<int> setLabelType(int labelType) async {
    return (await methodChannel.invokeMethod<int>(
      'setLabelType',
      <String, dynamic>{
        'labelType': labelType,
      },
    )) as int;
  }

  @override
  Future<int> setPositioningCalibration(int positioningCalibration) async {
    return (await methodChannel.invokeMethod<int>(
      'setPositioningCalibration',
      <String, dynamic>{
        'positioningCalibration': positioningCalibration,
      },
    )) as int;
  }

  @override
  Future<int> setPrinterMode(int printerMode) async {
    return (await methodChannel.invokeMethod<int>(
      'setPrinterMode',
      <String, dynamic>{
        'printerMode': printerMode,
      },
    )) as int;
  }

  @override
  Future<int> setLabelMaterial(int labelMaterial) async {
    return (await methodChannel.invokeMethod<int>(
      'setLabelMaterial',
      <String, dynamic>{
        'labelMaterial': labelMaterial,
      },
    )) as int;
  }

  @override
  Future<int> setPrinterAutoShutdownTime(int printerAutoShutdownTime) async {
    return (await methodChannel.invokeMethod<int>(
      'setPrinterAutoShutdownTime',
      <String, dynamic>{
        'printerAutoShutdownTime': printerAutoShutdownTime,
      },
    )) as int;
  }

  @override
  Future<int> setPrinterReset() async {
    return (await methodChannel.invokeMethod<int>('setPrinterReset')) as int;
  }

  @override
  Future<int> setVolumeLevel(int volumeLevel) async {
    return (await methodChannel.invokeMethod<int>(
      'setVolumeLevel',
      <String, dynamic>{
        'volumeLevel': volumeLevel,
      },
    )) as int;
  }

  @override
  Future<void> setTotalQuantityOfPrints(int totalQuantityOfPrints) =>
      methodChannel.invokeMethod<void>(
        'setTotalQuantityOfPrints',
        <String, dynamic>{
          'totalQuantityOfPrints': totalQuantityOfPrints,
        },
      );

  @override
  Future<void> setIsBackground(bool isBackground) =>
      methodChannel.invokeMethod<void>(
        'setIsBackground',
        <String, dynamic>{
          'isBackground': isBackground,
        },
      );

  @override
  Future<double> getMultiple() async {
    return (await methodChannel.invokeMethod<double>(
      'getMultiple')) as double;
  }

  @override
  Future<int> getPrinterType() async {
    return (await methodChannel.invokeMethod<int>(
      'getPrinterType'
    )) as int;
  }

  @override
  Future<int> getPrinterDensity() async {
    return (await methodChannel.invokeMethod<int>(
        'getPrinterDensity'
    )) as int;
  }

  @override
  Future<int> getPrinterSpeed() async {
    return (await methodChannel.invokeMethod<int>(
        'getPrinterSpeed'
    )) as int;
  }

  @override
  Future<int> getLabelType() async {
    return (await methodChannel.invokeMethod<int>(
        'getLabelType'
    )) as int;
  }

  @override
  Future<int> getPrinterMode() async {
    return (await methodChannel.invokeMethod<int>(
        'getPrinterMode'
    )) as int;
  }

  @override
  Future<int> getPrinterLanguage() async {
    return (await methodChannel.invokeMethod<int>(
        'getPrinterLanguage'
    )) as int;
  }

  @override
  Future<int> getAutoShutDownTime() async {
    return (await methodChannel.invokeMethod<int>(
        'getAutoShutDownTime'
    )) as int;
  }

  @override
  Future<int> getPrinterElectricity() async {
    return (await methodChannel.invokeMethod<int>(
        'getPrinterElectricity'
    )) as int;
  }

  @override
  Future<int> getPrinterArea() async {
    return (await methodChannel.invokeMethod<int>(
        'getPrinterArea'
    )) as int;
  }

  @override
  Future<int> getPrinterColorType() async {
    return (await methodChannel.invokeMethod<int>(
        'getPrinterColorType'
    )) as int;
  }

  @override
  Future<String> getSdkVersion() async {
    return (await methodChannel.invokeMethod<String>(
        'getSdkVersion'
    )) as String;
  }

  @override
  Future<String> getPrinterSn() async {
    return (await methodChannel.invokeMethod<String>(
        'getPrinterSn'
    )) as String;
  }

  @override
  Future<String> getPrinterBluetoothAddress() async {
    return (await methodChannel.invokeMethod<String>(
        'getPrinterBluetoothAddress'
    )) as String;
  }

  @override
  Future<bool> isPrinterSupportWriteRfid() async {
    return (await methodChannel.invokeMethod<bool>(
        'isPrinterSupportWriteRfid'
    )) as bool;
  }

  @override
  Future<bool> isVer() async {
    return (await methodChannel.invokeMethod<bool>(
        'isVer'
    )) as bool;
  }

  @override
  Future<Map<dynamic, dynamic>> getPrinterRfidParameter() async {
    return (await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getPrinterRfidParameter'
    )) as Map<dynamic, dynamic>;
  }

  @override
  Future<List<Object?>> getPrinterRfidParameters() async {
    return (await methodChannel.invokeMethod<List<Object?>>(
        'getPrinterRfidParameters'
    )) as List<Object?>;
  }


  @override
  Future<Map<dynamic, dynamic>> getPrinterRfidSuccessTimes() async {
    return (await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getPrinterRfidSuccessTimes'
    )) as Map<dynamic, dynamic>;
  }


  @override
  Future<bool> isSupportGetPrinterHistory() async {
    return (await methodChannel.invokeMethod<bool>(
        'isSupportGetPrinterHistory'
    )) as bool;
  }

  @override
  Future<dynamic> getPrintingHistory() async {
    // return (await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
    return (await methodChannel.invokeMethod<dynamic>(
        'getPrinterElectricity'
    ));
  }

}

dynamic _parseHandbook(String src) {
  return json.decode(src) as List<dynamic>;
}
