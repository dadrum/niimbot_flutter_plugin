package com.devroom.niimbot_test

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import com.devroom.niimbot_test.streams.BtDeviceFoundStreamHandler
import com.devroom.niimbot_test.streams.PrintProcessCallbackStreamHandler
import com.devroom.niimbot_test.streams.PrinterCallbackStreamHandler
import com.devroom.niimbot_test.utils.ClsUtils
import com.devroom.niimbot_test.utils.PrintUtil
import com.gengcon.www.jcprintersdk.callback.Callback
import com.gengcon.www.jcprintersdk.callback.PrintCallback
import com.google.common.util.concurrent.ThreadFactoryBuilder
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.LinkedBlockingDeque
import java.util.concurrent.ThreadFactory
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var onBtDeviceFoundChannel: EventChannel
    private lateinit var onPrinterCallbackChannel: EventChannel
    private lateinit var onPrintProcessCallbackChannel: EventChannel
//    private lateinit var context: Context

    private var executorService: ExecutorService? = null

    //контроллер для отправки уведомления о том, что принтер найден
    private var onBtDeviceFoundStreamHandler: BtDeviceFoundStreamHandler? = null
    private var onPrinterCallbackStreamHandler: PrinterCallbackStreamHandler? = null
    private var onPrintProcessCallbackStreamHandler: PrintProcessCallbackStreamHandler? = null

    private var mBluetoothAdapter: BluetoothAdapter? = null

    // ---------------------------------------------------------------------------------------------
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "niimbot")
        channel.setMethodCallHandler(this)
        // ***********************************
        // событие о том, что найден принтер
        onBtDeviceFoundChannel =
            EventChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "niimbot_on_bt_device_found_channel"
            )
        onBtDeviceFoundStreamHandler = BtDeviceFoundStreamHandler()
        onBtDeviceFoundChannel.setStreamHandler(onBtDeviceFoundStreamHandler)

        // ***********************************
        // колбэки от принтера
        onPrinterCallbackChannel =
            EventChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "niimbot_on_printer_callback_channel"
            )
        onPrinterCallbackStreamHandler = PrinterCallbackStreamHandler()
        onPrinterCallbackChannel.setStreamHandler(onPrinterCallbackStreamHandler)

        // ***********************************
        // колбэки о ходе печати принтера
        onPrintProcessCallbackChannel =
            EventChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "niimbot_on_print_process_callback_channel"
            )
        onPrintProcessCallbackStreamHandler = PrintProcessCallbackStreamHandler()
        onPrintProcessCallbackChannel.setStreamHandler(onPrintProcessCallbackStreamHandler)

        PrintUtil.initialize(context, printerCallback)

    }

    // ---------------------------------------------------------------------------------------------
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {

            "initialize" -> {
                initialize()
                result.success(null)
            }

            "scanPrinters" -> {
                scanPrinters()
                result.success(null)
            }

            "isConnected" -> {
                result.success(PrintUtil.instance.isConnection)
            }

            "close" -> {
                printClose()
                result.success(null)
            }

            "connectToPrinter" -> {
                connectToPrinter(
                    call.argument<String>("deviceAddress")!!,
                )
                result.success(null)
            }

            "startPrintJob" -> {
                PrintUtil.instance.startPrintJob(
                    call.argument<Int>("density")!!,
                    call.argument<Int>("paperType")!!,
                    call.argument<Int>("printMode")!!,
                    printCallback,
                )
                result.success(null)
            }

            "commitData" -> {
                PrintUtil.instance.commitData(
                    call.argument<List<String>>("printDataList")!!,
                    call.argument<List<String>>("printerInfoList")!!,
                )
                result.success(null)
            }

            "endJob" -> {
                result.success(PrintUtil.instance.endJob())
            }

            "cancelJob" -> {
                result.success(PrintUtil.instance.cancelJob())
            }

            "setPrinterDensity" -> {
                result.success(
                    PrintUtil.instance.setPrinterDensity(
                        call.argument<Int>("printerDensity")!!,
                    )
                )
            }

            "setPrinterSpeed" -> {
                result.success(
                    PrintUtil.instance.setPrinterSpeed(
                        call.argument<Int>("printerSpeed")!!,
                    )
                )
            }

            "setLabelType" -> {
                result.success(
                    PrintUtil.instance.setLabelType(
                        call.argument<Int>("labelType")!!,
                    )
                )
            }

            "setPositioningCalibration" -> {
                result.success(
                    PrintUtil.instance.setPositioningCalibration(
                        call.argument<Int>("positioningCalibration")!!,
                    )
                )
            }

            "setPrinterMode" -> {
                result.success(
                    PrintUtil.instance.setPrinterMode(
                        call.argument<Int>("printerMode")!!,
                    )
                )
            }

            "setPrintLanguage" -> {
                result.success(
                    PrintUtil.instance.setPrintLanguage(
                        call.argument<Int>("printLanguage")!!,
                    )
                )
            }

            "setLabelMaterial" -> {
                result.success(
                    PrintUtil.instance.setLabelMaterial(
                        call.argument<Int>("labelMaterial")!!,
                    )
                )
            }

            "setPrinterAutoShutdownTime" -> {
                result.success(
                    PrintUtil.instance.setPrinterAutoShutdownTime(
                        call.argument<Int>("printerAutoShutdownTime")!!,
                    )
                )
            }

            "setPrinterReset" -> {
                result.success(
                    PrintUtil.instance.setPrinterReset()
                )
            }

            "setVolumeLevel" -> {
                result.success(
                    PrintUtil.instance.setVolumeLevel(
                        call.argument<Int>("volumeLevel")!!,
                    )
                )
            }

            "setTotalQuantityOfPrints" -> {
                PrintUtil.instance.setTotalQuantityOfPrints(
                    call.argument<Int>("totalQuantityOfPrints")!!,
                )
                result.success(null)
            }

            "setIsBackground" -> {
                PrintUtil.instance.setIsBackground(
                    call.argument<Boolean>("isBackground")!!,
                )
                result.success(null)
            }


            "getMultiple" -> {
                result.success(
                    PrintUtil.instance.multiple
                )
            }

            "getPrinterType" -> {
                result.success(
                    PrintUtil.instance.printerType
                )
            }

            "getPrinterDensity" -> {
                result.success(
                    PrintUtil.instance.printerDensity
                )
            }

            "getPrinterSpeed" -> {
                result.success(
                    PrintUtil.instance.printerSpeed
                )
            }

            "getLabelType" -> {
                result.success(
                    PrintUtil.instance.labelType
                )
            }

            "getPrinterMode" -> {
                result.success(
                    PrintUtil.instance.printerMode
                )
            }

            "getPrinterLanguage" -> {
                result.success(
                    PrintUtil.instance.printerLanguage
                )
            }

            "getAutoShutDownTime" -> {
                result.success(
                    PrintUtil.instance.autoShutDownTime
                )
            }

            "getPrinterElectricity" -> {
                result.success(
                    PrintUtil.instance.printerElectricity
                )
            }

            "getPrinterArea" -> {
                result.success(
                    PrintUtil.instance.printerArea
                )
            }

            "getPrinterSn" -> {
                result.success(
                    PrintUtil.instance.printerSn
                )
            }

            "getPrinterBluetoothAddress" -> {
                result.success(
                    PrintUtil.instance.printerBluetoothAddress
                )
            }

            "isPrinterSupportWriteRfid" -> {
                result.success(
                    PrintUtil.instance.isPrinterSupportWriteRfid
                )
            }

            "isVer" -> {
                result.success(
                    PrintUtil.instance.isVer
                )
            }

            "getPrinterRfidParameter" -> {
                result.success(
                    PrintUtil.instance.printerRfidParameter
                )
            }

            "getPrinterRfidParameters" -> {
                result.success(
                    PrintUtil.instance.printerRfidParameters
                )
            }

            "getPrinterRfidSuccessTimes" -> {
                result.success(
                    PrintUtil.instance.printerRfidSuccessTimes
                )
            }

            "isSupportGetPrinterHistory" -> {
                result.success(
                    PrintUtil.instance.isSupportGetPrinterHistory
                )
            }

            "getPrintingHistory" -> {
                result.success(
                    PrintUtil.instance.printingHistory
                )
            }

            "getPrinterColorType" -> {
                result.success(
                    PrintUtil.instance.printerColorType
                )
            }

            "getSdkVersion" -> {
                result.success(
                    PrintUtil.instance.sdkVersion
                )
            }

            "initImageProcessingDefault" -> {
                PrintUtil.instance.initImageProcessingDefault(
                    call.argument<String>("fontFamilyPath")!!,
                    call.argument<String>("defaultFamilyPath")!!,
                )
                result.success(null)
            }

            "drawEmptyLabel" -> {
                PrintUtil.instance.drawEmptyLabel(
                    call.argument<Float>("width")!!,
                    call.argument<Float>("height")!!,
                    call.argument<Int>("rotate")!!,
                    call.argument<String>("fontDir")!!,
                )
                result.success(null)
            }

            "commitImageData" -> {
                PrintUtil.instance.commitImageData(
                    call.argument<Int>("orientation")!!,
                    call.argument<Bitmap>("printBitmap")!!,
                    call.argument<Int>("pageWidth")!!,
                    call.argument<Int>("pageHeight")!!,
                    call.argument<Int>("quantity")!!,
                    call.argument<Int>("marginTop")!!,
                    call.argument<Int>("marginLeft")!!,
                    call.argument<Int>("marginBottom")!!,
                    call.argument<Int>("marginRight")!!,
                    call.argument<String>("rfid")!!,
                )
                result.success(null)
            }

            "drawLabelText" -> {
                PrintUtil.instance.drawLabelText(
                    call.argument<Float>("x")!!,
                    call.argument<Float>("y")!!,
                    call.argument<Float>("width")!!,
                    call.argument<Float>("height")!!,
                    call.argument<String>("value")!!,
                    call.argument<String>("fontFamily")!!,
                    call.argument<Float>("fontSize")!!,
                    call.argument<Int>("rotate")!!,
                    // Выравнивание по горизонтали: 0: Выравнивание по левому краю 1: Выравнивание по центру 2: Выравнивание по правому краю
                    call.argument<Int>("textAlignHorizontal")!!,
                    // Выравнивание по вертикали: 0: Выравнивание по верху 1: Центрирование по вертикали 2: Выравнивание по низу
                    call.argument<Int>("textAlignVertical")!!,
                    // 1: Фиксированная ширина и высота, адаптивный размер содержимого (размер шрифта / межсимвольный интервал / межстрочный интервал масштабируется по масштабу) 2: Фиксированная ширина, адаптивная высота 3: фиксированные ширина и высота, добавляются после превышения содержимого...4: Фиксированная ширина и высота, прямая вырезка за пределы содержимого 6: Фиксированная ширина и высота, автоматическое сокращение, когда содержимое превышает заданные ширину и высоту (размер шрифта / межсимвольный интервал / межстрочный интервал масштабируются в соответствии с масштабом)
                    call.argument<Int>("lineModel")!!,
                    // Стандартный интервал между буквами в мм
                    call.argument<Float>("letterSpace")!!,
                    // Межстрочный интервал (временный интервал), единица измерения мм
                    call.argument<Float>("lineSpace")!!,
                    // стиль шрифта [полужирный, курсив, подчеркивание, удалить подчеркивание (зарезервировано)]
                    call.argument<ArrayList<Boolean>>("mFontStyles")!!.toBooleanArray(),
                )
                result.success(null)
            }

            "drawLabelBarCode" -> {
                PrintUtil.instance.drawLabelBarCode(
                    call.argument<Float>("x")!!,
                    call.argument<Float>("y")!!,
                    // Ширина штрих-кода, мм.
                    call.argument<Float>("width")!!,
                    // Высота штрих-кода, мм
                    call.argument<Float>("height")!!,
                    // Тип штрих-кода. Тип по умолчанию 20
                    // 20:CODE128
                    // 21:UPC-A
                    // 22:UPC-E
                    // 23:EAN8
                    // 24:EAN13
                    // 25:CODE93
                    // 26:CODE39
                    // 27:CODEBAR
                    // 28:ITF25
                    call.argument<Int>("codeType")!!,
                    // содержимое штрих-кода
                    call.argument<String>("value")!!,
                    // Размер шрифта, мм. По умолчанию — 4 мм.
                    call.argument<Float>("fontSize")!!,
                    // Угол поворота артборда, по умолчанию — 0, без вращения. Поддерживаемые углы поворота 0, 90, 180, 270.
                    call.argument<Int>("rotate")!!,
                    // Высота текста. Высота по умолчанию составляет 4 мм.
                    call.argument<Int>("textHeight")!!,
                    // Положение текста штрих-кода. По умолчанию — 0. * 0: отображается ниже * 1: отображается вверху * 2: не отображается
                    call.argument<Int>("textPosition")!!,
                )
                result.success(null)
            }

            "drawLabelQrCode" -> {
                PrintUtil.instance.drawLabelQrCode(
                    call.argument<Float>("x")!!,
                    call.argument<Float>("y")!!,
                    // Ширина штрих-кода, мм.
                    call.argument<Float>("width")!!,
                    // Высота штрих-кода, мм
                    call.argument<Float>("height")!!,
                    // Содержимое QR-кода
                    call.argument<String>("value")!!,
                    // Угол поворота артборда, по умолчанию — 0, без вращения. Поддерживаемые углы поворота 0, 90, 180, 270.
                    call.argument<Int>("rotate")!!,
                    // Тип QR-кода, тип по умолчанию 31.
                    //31:QR_CODE
                    //32:PDF417
                    //33:DATA_MATRIX
                    //34:AZTEC
                    call.argument<Int>("codeType")!!,
                )
                result.success(null)
            }


            "drawLabelGraph" -> {
                PrintUtil.instance.drawLabelGraph(
                    call.argument<Float>("x")!!,
                    call.argument<Float>("y")!!,
                    // Ширина штрих-кода, мм.
                    call.argument<Float>("width")!!,
                    // Высота штрих-кода, мм
                    call.argument<Float>("height")!!,
                    // Тип изображения, тип по умолчанию — 1. 1: Круг, 2: Эллипс, 3: Прямоугольник, 4: Прямоугольник со скругленными углами.
                    call.argument<Int>("graphType")!!,
                    // Угол поворота артборда, по умолчанию — 0, без вращения. Поддерживаемые углы поворота 0, 90, 180, 270.
                    call.argument<Int>("rotate")!!,
                    // Угловой радиус, ед. мм
                    call.argument<Float>("cornerRadius")!!,
                    // Ширина линии
                    call.argument<Float>("lineWidth")!!,
                    // Тип линии, тип по умолчанию — 1. 1: сплошная линия, 2: пунктирная линия.
                    call.argument<Int>("lineType")!!,
                    // Параметры пунктирных линий
                    call.argument<ArrayList<Float>>("dashWidth")!!.toFloatArray(),
                )
                result.success(null)
            }

            "drawLabelImage" -> {
                PrintUtil.instance.drawLabelImage(
                    call.argument<String>("imageData")!!,
                    call.argument<Float>("x")!!,
                    call.argument<Float>("y")!!,
                    call.argument<Float>("width")!!,
                    call.argument<Float>("height")!!,
                    call.argument<Int>("rotate")!!,
                    call.argument<Int>("imageProcessingType")!!,
                    call.argument<Float>("imageProcessingValue")!!,
                )
                result.success(null)
            }

            "drawLabelLine" -> {
                PrintUtil.instance.drawLabelLine(
                    call.argument<Float>("x")!!,
                    call.argument<Float>("y")!!,
                    call.argument<Float>("width")!!,
                    call.argument<Float>("height")!!,
                    call.argument<Int>("rotate")!!,
                    call.argument<Int>("lineType")!!,
                    call.argument<ArrayList<Float>>("dashWidth")!!.toFloatArray(),
                )
                result.success(null)
            }

            "generateLabelJson" -> {
                val ret = PrintUtil.instance.generateLabelJson();
                result.success(ret)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    // ---------------------------------------------------------------------------------------------
    private val printCallback: PrintCallback = object : PrintCallback {
        override fun onProgress(
            pageIndex: Int,
            quantityIndex: Int,
            hashMap: HashMap<String, Any>?
        ) {
            runOnUiThread {
                onPrintProcessCallbackStreamHandler?.sendEvent(
                    Constant.ON_PRINT_PROGRESS,
                    pageIndex,
                    quantityIndex,
                    hashMap,
                )
            }
        }

        override fun onError(errorCode: Int) {
            runOnUiThread {
                onPrintProcessCallbackStreamHandler?.sendEvent(
                    Constant.ON_PRINT_ERROR,
                    errorCode,
                )
            }
        }

        override fun onError(errorCode: Int, printState: Int) {
            runOnUiThread {
                onPrintProcessCallbackStreamHandler?.sendEvent(
                    Constant.ON_PRINT_ERROR,
                    errorCode,
                    printState,
                )
            }
        }

        override fun onCancelJob(isSuccess: Boolean) {
            runOnUiThread {
                onPrintProcessCallbackStreamHandler?.sendEvent(
                    Constant.ON_PRINT_CANCEL_JOB,
                    isSuccess,
                )
            }
        }

        override fun onBufferFree(pageIndex: Int, bufferSize: Int) {
            runOnUiThread {
                onPrintProcessCallbackStreamHandler?.sendEvent(
                    Constant.ON_BUFFER_FREE,
                    pageIndex,
                    bufferSize,
                )
            }
        }
    }

    // ---------------------------------------------------------------------------------------------
    private val printerCallback: Callback = object : Callback {
        override fun onConnectSuccess(s: String) {
            runOnUiThread {
                onPrinterCallbackStreamHandler?.sendEvent(Constant.ON_CONNECT_SUCCESS, s)
            }
        }

        override fun onDisConnect() {
            runOnUiThread {
                onPrinterCallbackStreamHandler?.sendEvent(Constant.ON_DISCONNECT)
            }
        }

        override fun onElectricityChange(i: Int) {
            runOnUiThread {
                onPrinterCallbackStreamHandler?.sendEvent(Constant.ON_ELECTRICITY_CHANGE, i)
            }
        }

        override fun onCoverStatus(i: Int) {
            runOnUiThread {
                onPrinterCallbackStreamHandler?.sendEvent(Constant.ON_COVER_STATUS, i)
            }
        }

        override fun onPaperStatus(i: Int) {
            runOnUiThread {
                onPrinterCallbackStreamHandler?.sendEvent(Constant.ON_PAPER_STATUS, i)
            }
        }

        override fun onRfidReadStatus(i: Int) {
            runOnUiThread {
                onPrinterCallbackStreamHandler?.sendEvent(Constant.ON_RFID_READ_STATUS, i)
            }
        }

        override fun onPrinterIsFree(i: Int) {
            runOnUiThread {
                onPrinterCallbackStreamHandler?.sendEvent(Constant.ON_PRINTER_IS_FREE, i)
            }
        }

        override fun onHeartDisConnect() {
            runOnUiThread {
                onPrinterCallbackStreamHandler?.sendEvent(Constant.ON_HEART_DISCONNECT)
            }
        }

        override fun onFirmErrors() {
            runOnUiThread {
                onPrinterCallbackStreamHandler?.sendEvent(Constant.ON_FIRM_ERRORS)
            }
        }
    }


    // ---------------------------------------------------------------------------------------------
    private fun printClose() {
        if (PrintUtil.instance.isConnection != -1) {
            PrintUtil.instance.close()
        }
    }

    // ---------------------------------------------------------------------------------------------
    private fun initialize() {
        if (mBluetoothAdapter == null) {
            val bluetoothManager =
                context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
            mBluetoothAdapter = bluetoothManager.adapter
        }

        // Зарегистрироваться для трансляции
        val intentFilter = IntentFilter()
        intentFilter.addAction(BluetoothDevice.ACTION_FOUND)
        intentFilter.addAction(BluetoothAdapter.ACTION_DISCOVERY_STARTED)
        intentFilter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        intentFilter.addAction(BluetoothDevice.ACTION_BOND_STATE_CHANGED)
        intentFilter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
        intentFilter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        intentFilter.addAction(BluetoothDevice.ACTION_PAIRING_REQUEST)
        context.registerReceiver(receiver, intentFilter)

        //Зарегистрировать пул потоков
        if (executorService == null) {
            val threadFactory: ThreadFactory = ThreadFactoryBuilder()
                .setNameFormat("connect_activity_pool_%d").build()
            executorService = ThreadPoolExecutor(
                1,
                1,
                0L,
                TimeUnit.MILLISECONDS,
                LinkedBlockingDeque<Runnable>(1024),
                threadFactory,
                ThreadPoolExecutor.AbortPolicy()
            )
        }
    }


    // ---------------------------------------------------------------------------------------------
    private fun scanPrinters() {
        if (mBluetoothAdapter == null) {
            initialize()
        }
        Log.v("NIIMBOT_BT", "ActivityCompat.checkSelfPermission")
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.BLUETOOTH_SCAN
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        if (mBluetoothAdapter!!.isDiscovering) {
            Log.v("NIIMBOT_BT", "mBluetoothAdapter!!.isDiscovering")
            if (mBluetoothAdapter!!.cancelDiscovery()) {
                Log.v("NIIMBOT_BT", "mBluetoothAdapter!!.cancelDiscovery()")
                try {
                    //После отмены подождите 1 секунду и повторите поиск
                    Thread.sleep(1000)
                    Log.v("NIIMBOT_BT", "mBluetoothAdapter!!.startDiscovery()")
                    mBluetoothAdapter!!.startDiscovery()
                } catch (e: InterruptedException) {
                    e.printStackTrace()
                }
            }
        } else {
            Log.v("NIIMBOT_BT", "mBluetoothAdapter!!.startDiscovery()")
            mBluetoothAdapter!!.startDiscovery()
        }

    }

    // ---------------------------------------------------------------------------------------------
    private val receiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            Log.v("NIIMBOT_BT", "receiver onReceive")
            val action = intent.action
            //Обнаружение Bluetooth
            if (BluetoothDevice.ACTION_FOUND == action) {

                @Suppress("DEPRECATION") val device =
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(
                            BluetoothDevice.EXTRA_DEVICE,
                            BluetoothDevice::class.java
                        )
                    } else {
                        intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
                    }

                if (device != null) {
                    if (ActivityCompat.checkSelfPermission(
                            context,
                            Manifest.permission.BLUETOOTH_CONNECT
                        ) != PackageManager.PERMISSION_GRANTED
                    ) {
                        return
                    }
                    val supportBluetoothType =
                        device.type == BluetoothDevice.DEVICE_TYPE_CLASSIC || device.type == BluetoothDevice.DEVICE_TYPE_DUAL
                    if (supportBluetoothType) {
                        Log.v("NIIMBOT_BT", "supportBluetoothType->${device}")

                        onBtDeviceFoundStreamHandler?.sendDevice(device)
                    } else {
                        Log.v("NIIMBOT_BT", "supportBluetoothType - X > $device")
                    }
                }
            } else if (BluetoothAdapter.ACTION_DISCOVERY_STARTED == action) {
                Log.v("NIIMBOT_BT", "ACTION_DISCOVERY_STARTED")
            } else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED == action) {
                Log.v("NIIMBOT_BT", "ACTION_DISCOVERY_FINISHED")
            } else if (BluetoothDevice.ACTION_BOND_STATE_CHANGED == action) {
                Log.v("NIIMBOT_BT", "ACTION_BOND_STATE_CHANGED")
                Log.v("NIIMBOT_BT", intent.extras.toString())
                Log.v(
                    "NIIMBOT_BT",
                    intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, -1).toString()
                )
            }
        }
    }

    // ---------------------------------------------------------------------------------------------
    @SuppressLint("MissingPermission")
    private fun connectToPrinter(
        deviceAddress: String,
    ) {
        if (mBluetoothAdapter == null) {
            initialize()
        }

        executorService!!.submit {
            val bluetoothDevice: BluetoothDevice =
                mBluetoothAdapter!!.getRemoteDevice(deviceAddress)

            var returnValue = true
            if (bluetoothDevice.bondState == Constant.NO_BOND) {
                runOnUiThread {
                    onPrinterCallbackStreamHandler?.sendEvent(Constant.TRY_TO_CREATE_BOUND)
                }
                try {
                    returnValue = ClsUtils.createBond(bluetoothDevice.javaClass, bluetoothDevice)
                } catch (e: Exception) {
                    runOnUiThread {
                        onPrinterCallbackStreamHandler?.sendEvent(Constant.BOUND_FAILED, e)
                    }
                }
            }

            if (returnValue) {
                val isConnection = PrintUtil.instance.isConnection
                if (isConnection == -1) {
                    runOnUiThread {
                        onPrinterCallbackStreamHandler?.sendEvent(Constant.TRY_TO_OPEN_PRINTER)
                    }
                    val connectResult: Int =
                        PrintUtil.instance.openPrinterByAddress(deviceAddress)
                    runOnUiThread {

                        onPrinterCallbackStreamHandler?.sendEvent(
                            Constant.OPEN_PRINTER_RESULT,
                            connectResult
                        )
                    }
//                    when (connectResult) {
//                        0 -> {
//                            lastConnectedDevice = blueDeviceList.get(position)
//                            lastConnectedDevice.setConnectState(13)
//                            blueDeviceList.remove(position)
//                            hint = "Успешное подключение"
//                            val preferences =
//                                context.getSharedPreferences(
//                                    "printConfiguration",
//                                    MODE_PRIVATE
//                                )
//                            val editor = preferences.edit()
//                            val printerName: String = blueDeviceInfo.getDeviceName()
//                            if (printerName.matches("^(B32|Z401|B50|T6|T7|T8).*".toRegex())) {
//                                editor.putInt("printMode", 2)
//                                editor.putInt("printDensity", 8)
//                                editor.putFloat("printMultiple", 11.81f)
//                            } else {
//                                editor.putInt("printMode", 1)
//                                editor.putInt("printDensity", 3)
//                                editor.putFloat("printMultiple", 8f)
//                            }
//                            editor.apply() //提交修改
                }

//                        -1 -> hint = "Сбой подключения"
//                        -2 -> hint = "Неподдерживаемые модели"
//                        else -> {
//                            hint = "xxx"
//                        }
//                    }
//                    Log.d(
//                        "NIIMBOT_BT",
//                        hint
//                    )
//                }


            }

        }
//        Log.d(
//            "NIIMBOT_BT",
//            "executorRes = " + executorRes.toString()
//        )


    }
}

