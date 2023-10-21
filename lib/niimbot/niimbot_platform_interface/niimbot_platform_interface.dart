import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../models/bt_printer_info.dart';
import '../models/device_guide.dart';
import '../models/device_module.dart';
import '../models/print_process_event.dart';
import '../models/printer_state_event.dart';

abstract class NiimbotPlatform extends PlatformInterface {
  NiimbotPlatform() : super(token: _token);

  static final Object _token = Object();

  Future<void> initialize();

  Future<void> scanPrinters();

  Future<int> isConnected();

  Future<void> close();

  Future<void> connectToPrinter(String printerAddress);

  Stream<BtDeviceInfo> get newBtDeviceStream;

  Stream<NiimbotPrinterStateEvent> get printerCallbackStream;

  Stream<NiimbotPrintProcessEvent> get printProcessCallbackStream;

  // ---------------------------------------------------------------------------
  Future<Iterable<DeviceModule>> getDevicesConfigurations();

  // ---------------------------------------------------------------------------
  Future<Iterable<DeviceGuide>> getDevicesGuides();

  // ---------------------------------------------------------------------------
  Future<void> startPrintJob(
      {required int density, required int paperType, required int printMode});

  // ---------------------------------------------------------------------------
  /// отправка данных в виде JSON
  Future<void> commitData({
    /// данные для печати
    required List<String> printDataList,

    /// список информации о принтере
    required List<String> printerInfoList,
  });

  // ---------------------------------------------------------------------------
  /// отправка растрового изображения
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
  });

  // ---------------------------------------------------------------------------
  /// метод, вызываемый после печати последней страницы, чтобы отметить
  /// завершенность предыдущего задания перед запуском startJob
  Future<bool> endJob();

  // ---------------------------------------------------------------------------
  /// метод для отмены текущего задания
  Future<void> cancelJob();

  // ---------------------------------------------------------------------------
  ///
  Future<int> setPrintLanguage(int printLanguage);
  Future<int> setPrinterDensity(int printerDensity);
  Future<int> setPrinterSpeed(int printerSpeed);
  Future<int> setLabelType(int labelType);
  Future<int> setPositioningCalibration(int positioningCalibration);
  Future<int> setPrinterMode(int printerMode);
  Future<int> setLabelMaterial(int labelMaterial);
  Future<int> setPrinterAutoShutdownTime(int printerAutoShutdownTime);
  Future<int> setPrinterReset();
  Future<int> setVolumeLevel(int volumeLevel);
  Future<void> setTotalQuantityOfPrints(int totalQuantityOfPrints);
  Future<void> setIsBackground(bool isBackground);
  Future<double> getMultiple();
  Future<int> getPrinterType();
  Future<int> getPrinterDensity();
  Future<int> getPrinterSpeed();
  Future<int> getLabelType();
  Future<int> getPrinterMode();
  Future<int> getPrinterLanguage();
  Future<int> getAutoShutDownTime();
  Future<int> getPrinterElectricity();
  Future<int> getPrinterArea();
  Future<int> getPrinterColorType();
  Future<String> getSdkVersion();
  Future<String> getPrinterSn();
  Future<String> getPrinterBluetoothAddress();
  Future<bool> isPrinterSupportWriteRfid();
  Future<bool> isVer();
  Future<Map<dynamic, dynamic>> getPrinterRfidParameter();
  Future<List<Object?>> getPrinterRfidParameters();
  Future<Map<dynamic, dynamic>> getPrinterRfidSuccessTimes();
  Future<bool> isSupportGetPrinterHistory();
  Future<dynamic> getPrintingHistory();

  // ---------------------------------------------------------------------------
  /// инициализация шрифта
  Future<void> initImageProcessingDefault({
    /// путь к шрифту
    required String fontFamilyPath,

    /// шрифт по-умолчанию
    required String defaultFamilyPath,
  });

  // ---------------------------------------------------------------------------
  /// инициализация пустого артборда
  Future<void> drawEmptyLabel({
    /// ширина (мм)
    required double width,

    /// высота (мм)
    required double height,

    /// угол поворота 0/90/180/270
    required int rotate,

    /// путь к шрифту (в настоящее время не поддерживается). По-умолчанию - пустая строка
    required String fontDir,
  });

  // ---------------------------------------------------------------------------
  /// инициализация артборда с текстом
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
  });

  // ---------------------------------------------------------------------------
  /// рисование линейного кода
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
  });

  // ---------------------------------------------------------------------------
  /// рисование двухмерного кода
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
  });

  // ---------------------------------------------------------------------------
  /// рисование фигур
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
  });

  // ---------------------------------------------------------------------------
  /// рисование изображений
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
  });

  // ---------------------------------------------------------------------------
  /// рисование линий
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
  });

  // ---------------------------------------------------------------------------
  /// выгрузка изображения в формате JSON
  // TODO уточнить тип данных
  Future<dynamic> generateLabelJson();
}
