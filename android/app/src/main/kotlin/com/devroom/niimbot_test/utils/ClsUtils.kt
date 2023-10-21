package com.devroom.niimbot_test.utils

import android.bluetooth.BluetoothDevice


object ClsUtils {
    @Throws(Exception::class)
    fun createBond(
        btClass: Class<*>,
        btDevice: BluetoothDevice?
    ): Boolean {
        val createBondMethod = btClass.getMethod("createBond")
        return createBondMethod.invoke(btDevice) as Boolean
    }
}
