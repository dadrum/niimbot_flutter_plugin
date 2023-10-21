package com.devroom.niimbot_test

class BlueDeviceInfo(
    var deviceName: String,
    var deviceHardwareAddress: String,
    var connectState: Int
) {

    override fun hashCode(): Int {
        return deviceName.hashCode()
    }

    override fun equals(obj: Any?): Boolean {
        val blueDeviceInfo = obj as BlueDeviceInfo?
        return if (blueDeviceInfo != null) {
            deviceName == blueDeviceInfo.deviceName
        } else false
    }
}