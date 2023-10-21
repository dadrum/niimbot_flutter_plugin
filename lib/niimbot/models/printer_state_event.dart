import 'package:flutter/foundation.dart';

import 'connect_result_type.dart';

sealed class NiimbotPrinterStateEvent {}

// CONNECTION EVENTS
// -----------------------------------------------------------------------------
// Trying to bound printer
class NimmbotEventTryToCreateBound extends NiimbotPrinterStateEvent {
  @override
  String toString() {
    return 'NimmbotEventTryToCreateBound';
  }
}

// Trying to bound printer
class NimmbotEventBoundFailed extends NiimbotPrinterStateEvent {
  @override
  String toString() {
    return 'NimmbotEventBoundFailed';
  }
}

// Trying to open printer
class NimmbotEventTryToOpenPrinter extends NiimbotPrinterStateEvent {
  @override
  String toString() {
    return 'NimmbotEventTryToOpenPrinter';
  }
}

// public final static String OPEN_PRINTER_RESULT = "openPrinterResult";
// Printer connection result
@immutable
class NimmbotConnectResult extends NiimbotPrinterStateEvent {
  NimmbotConnectResult(this.status);

  // 0 = "Успешное подключение"
  // -1 = "Сбой подключения"
  // -2 = "Занято" (Только B21)
  // -3 = "не поддерживается"
  final NimmbotConnectResultType status;

  @override
  String toString() {
    return 'NimmbotConnectResult($status)';
  }
}

// STATE EVENTS
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
class NimmbotEventOnDisconnected extends NiimbotPrinterStateEvent {
  @override
  String toString() {
    return 'NimmbotEventOnDisconnected';
  }
}

// -----------------------------------------------------------------------------
@immutable
class NimmbotEventOnConnected extends NiimbotPrinterStateEvent {
  NimmbotEventOnConnected(this.value);

  final String value;

  @override
  String toString() {
    return 'NimmbotEventOnConnected($value)';
  }
}

// -----------------------------------------------------------------------------
/// уровень питания?
@immutable
class NimmbotEventOnElectricityChanged extends NiimbotPrinterStateEvent {
  NimmbotEventOnElectricityChanged(this.value);

  /// [1..4]
  final int value;

  @override
  String toString() {
    return 'NimmbotEventOnElectricityChanged($value)';
  }
}

// -----------------------------------------------------------------------------
/// состояние закрытия крышки
@immutable
class NimmbotEventOnCoverStatus extends NiimbotPrinterStateEvent {
  NimmbotEventOnCoverStatus(this.value);

  /// 0 = крышка закрыта, 1 = крышка открыти
  final int value;

  @override
  String toString() {
    return 'NimmbotEventOnCoverStatus($value)';
  }
}

// -----------------------------------------------------------------------------
/// изменение статуса бумаги
@immutable
class NimmbotEventOnPaperStatus extends NiimbotPrinterStateEvent {
  NimmbotEventOnPaperStatus(this.value);

  /// 0 = есть бумага, 1 = бумага закончилась
  final int value;

  @override
  String toString() {
    return 'NimmbotEventOnPaperStatus($value)';
  }
}

// -----------------------------------------------------------------------------
@immutable
class NimmbotEventOnRfidReadStatus extends NiimbotPrinterStateEvent {
  NimmbotEventOnRfidReadStatus(this.value);

  final int value;

  @override
  String toString() {
    return 'NimmbotEventOnRfidReadStatus($value)';
  }
}

// -----------------------------------------------------------------------------
/// статус занятости принтера
@immutable
class NimmbotEventOnPrinterIsFree extends NiimbotPrinterStateEvent {
  NimmbotEventOnPrinterIsFree(this.value);

  /// 0 = занят, 1 = свободен
  final int value;

  @override
  String toString() {
    return 'NimmbotEventOnPrinterIsFree($value)';
  }
}

// -----------------------------------------------------------------------------
/// событие о приостановке контрольных запросов к принтеру
class NimmbotEventOnHeartDisConnect extends NiimbotPrinterStateEvent {
  @override
  String toString() {
    return 'NimmbotEventOnHeartDisConnect';
  }
}

// -----------------------------------------------------------------------------
class NimmbotEventOnFirmErrors extends NiimbotPrinterStateEvent {
  @override
  String toString() {
    return 'NimmbotEventOnFirmErrors';
  }
}

// Events factory
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
class NiimbotPrinterStateEventFactory {
  static NiimbotPrinterStateEvent fromEventName(String eventName,
      dynamic parameter) {
    switch (eventName) {
      case 'tryToCreateBound':
        return NimmbotEventTryToCreateBound();
      case 'boundFailed':
        return NimmbotEventBoundFailed();
      case 'tryToOpenPrinter':
        return NimmbotEventTryToOpenPrinter();
      case 'openPrinterResult':
        return NimmbotConnectResult(_connectionResultMapper(parameter as int));
      case 'onDisconnect':
        return NimmbotEventOnDisconnected();
      case 'onConnectSuccess':
        return NimmbotEventOnConnected(parameter as String);
      case 'onElectricityChange':
        return NimmbotEventOnElectricityChanged(parameter as int);
      case 'onCoverStatus':
        return NimmbotEventOnCoverStatus(parameter as int);
      case 'onPaperStatus':
        return NimmbotEventOnPaperStatus(parameter as int);
      case 'onRfidReadStatus':
        return NimmbotEventOnRfidReadStatus(parameter as int);
      case 'onPrinterIsFree':
        return NimmbotEventOnPrinterIsFree(parameter as int);
      case 'onHeartDisConnect':
        return NimmbotEventOnHeartDisConnect();
      case 'onFirmErrors':
        return NimmbotEventOnFirmErrors();
      default:
        throw Exception('Invalid event name: $eventName');
    }
  }

  static NimmbotConnectResultType _connectionResultMapper(int type) =>
      switch(type) {
        0 => NimmbotConnectResultType.successfullyConnected,
        -1 => NimmbotConnectResultType.connectionError,
        -2 => NimmbotConnectResultType.busy,
        -3 => NimmbotConnectResultType.notSupported,
        _ => NimmbotConnectResultType.notSupported,
      };
}
