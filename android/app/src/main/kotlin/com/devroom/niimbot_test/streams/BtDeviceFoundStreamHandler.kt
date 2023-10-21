package com.devroom.niimbot_test.streams

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import io.flutter.plugin.common.EventChannel

class BtDeviceFoundStreamHandler : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null

    @SuppressLint("MissingPermission")
    fun sendDevice(deviceInfo: BluetoothDevice) {
        val map: HashMap<String, Any?> = hashMapOf(
            "bondState" to deviceInfo.bondState,
            "address" to deviceInfo.address,
            "type" to deviceInfo.type,
            "name" to deviceInfo.name,
            "bondState" to deviceInfo.uuids?.joinToString(separator = ",")
        )

        sink?.success(map)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }
}