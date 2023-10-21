import 'package:flutter/foundation.dart';

sealed class NiimbotPrintProcessEvent {}

// ---------------------------------------------------------------------------
/// событие о прогрессе выполнения работы
@immutable
class NimmbotEventPrintOnProgress extends NiimbotPrintProcessEvent {

  NimmbotEventPrintOnProgress(
      this.pageIndex,
      this.quantityIndex,
      this.hashMap,
      );
  /// количество напечатанных страниц
  final int pageIndex;

  /// количество напечатанных копий текущей страницы
  final int quantityIndex;

  /// для моделей, содержащих RFID
  final dynamic hashMap;

  @override
  String toString() {
    return 'NimmbotEventPrintOnProgress($pageIndex, $quantityIndex, $hashMap)';
  }
}

// ---------------------------------------------------------------------------
/// ошибка при выполнении работы
class NimmbotEventPrintOnError extends NiimbotPrintProcessEvent {

  NimmbotEventPrintOnError(this.errorCode, this.printState);

  /// 1 = открыта крышка
  /// 2 = нет бумаги
  /// 3 = недостаточный заряд батареи
  /// 4 = неисправность аккумулятора
  /// 5 = ручная остановка(кнопка)
  /// 6 = ошибка данных
  /// 7 = температура слишком высокая
  /// 8 = ненормальный вывод бумаги
  /// 9 = печать ?
  /// 10 = печатающая головка не обнаружена
  /// 11 = температура окружающей среды слишком низкая
  /// 12 = печатающая головка не заблокирована
  /// 13 = лента не обнаружена
  /// 14 = несоответствующая лента
  /// 15 = использованная лента
  /// 16 = неподдерживаемый тип бумаги
  /// 17 = не удалось установить тип бумаги
  /// 18 = не удалось настроить режим печати
  /// 19 = не удалось установить концентрацию
  /// 20 = не удалось записать RFID
  /// 21 = не удалось настроить поле
  /// 22 = нарушение связи
  /// 23 = соединение с принтером отключено
  /// 24 = ошибка параметра артборда
  /// 25 = неправильный угол поворота
  /// 26 = ошибка параметра json
  /// 27 = неисправность выброса бумаги (B3S)
  /// 28 = проверьте тип бумаги
  /// 29 = RFID-метка не записывается
  /// 30 = не поддерживает настройку концентрации
  /// 31 = неподдерживаемый тип печати
  final int errorCode;
  /// текущий статус печати
  /// 0 = печать
  /// 1 = печать приостановлена
  /// 2 = печать остановлена
  final int? printState;

  @override
  String toString() {
    return 'NimmbotEventPrintOnError($errorCode, $printState)';
  }
}

// ---------------------------------------------------------------------------
/// Выполнено прерывание печати
class NimmbotEventPrintOnCancelJob extends NiimbotPrintProcessEvent {

  NimmbotEventPrintOnCancelJob(this.isSuccess);
  final bool isSuccess;

  @override
  String toString() {
    return 'NimmbotEventPrintOnCancelJob($isSuccess)';
  }
}

// ---------------------------------------------------------------------------
/// Событие об оставшемся кеше
/// указывает, что существует незанятый кэш, который может продолжить
/// передавать данные
@immutable
class NimmbotEventPrintOnBufferFree extends NiimbotPrintProcessEvent {

  NimmbotEventPrintOnBufferFree(this.pageIndex, this.bufferSize);
  /// номер страницы, который нужно указать при запуске задачи. По-умолчанию 1
  final int pageIndex;

  /// количество незанятого места в памяти
  final int bufferSize;

  @override
  String toString() {
    return 'NimmbotEventPrintOnBufferFree($pageIndex, $bufferSize)';
  }
}

// Events factory
// -----------------------------------------------------------------------------
class NiimbotPrintProcessEventFactory {
  static NiimbotPrintProcessEvent fromEventName(
    String eventName,
    dynamic p1,
    dynamic p2,
    dynamic p3,
  ) {
    switch (eventName) {
      case 'onProgress':
        return NimmbotEventPrintOnProgress(
          p1 as int,
          p2 as int,
          p3 as dynamic,
        );
      case 'onError':
        return NimmbotEventPrintOnError(
          p1 as int,
          p2 as int?,
        );
      case 'onCancelJob':
        return NimmbotEventPrintOnCancelJob(
          p1 as bool,
        );
      case 'onBufferFree':
        return NimmbotEventPrintOnBufferFree(
          p1 as int,
          p2 as int,
        );
      default:
        throw Exception('Invalid event name: $eventName');
    }
  }
}
