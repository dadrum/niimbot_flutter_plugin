package com.devroom.niimbot_test;

/**
 * @author zhangbin
 */
public class Constant {
    public final static int NO_BOND = 10;
    public final static int BONDED = 12;
    public final static int CONNECTED = 13;

    // --------------------------------------------------------------
    // printer connection events
    public final static String TRY_TO_CREATE_BOUND = "tryToCreateBound";
    public final static String TRY_TO_OPEN_PRINTER = "tryToOpenPrinter";
    // 0="Успешное подключение"
    // -1="Сбой подключения"
    // -2="Неподдерживаемые модели"
    // x="неизвестное состояние"
    public final static String OPEN_PRINTER_RESULT = "openPrinterResult";

    public final static String BOUND_FAILED = "boundFailed";

    // --------------------------------------------------------------
    // printer callback events
    public final static String ON_CONNECT_SUCCESS = "onConnectSuccess";
    public final static String ON_DISCONNECT = "onDisconnect";
    public final static String ON_ELECTRICITY_CHANGE = "onElectricityChange";
    public final static String ON_COVER_STATUS = "onCoverStatus";
    public final static String ON_PAPER_STATUS = "onPaperStatus";
    public final static String ON_RFID_READ_STATUS = "onRfidReadStatus";
    public final static String ON_PRINTER_IS_FREE = "onPrinterIsFree";
    public final static String ON_HEART_DISCONNECT = "onHeartDisConnect";
    public final static String ON_FIRM_ERRORS = "onFirmErrors";


    // --------------------------------------------------------------
    // printer process callback events
    public final static String ON_PRINT_PROGRESS = "onProgress";
    public final static String ON_PRINT_ERROR = "onError";
    public final static String ON_PRINT_CANCEL_JOB = "onCancelJob";
    public final static String ON_BUFFER_FREE = "onBufferFree";

}
