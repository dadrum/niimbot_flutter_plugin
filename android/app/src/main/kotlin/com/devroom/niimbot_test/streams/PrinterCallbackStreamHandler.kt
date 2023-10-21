package com.devroom.niimbot_test.streams

import io.flutter.plugin.common.EventChannel

class PrinterCallbackStreamHandler : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null

    fun sendEvent(eventName: String, v1: Any? = null, v2: Any? = null) {
        val map: HashMap<String, Any?> = hashMapOf(
            "eventName" to eventName,
            "v1" to v1,
            "v2" to v2,
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