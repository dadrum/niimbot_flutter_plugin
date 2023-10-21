package com.devroom.niimbot_test

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import com.devroom.niimbot_test.streams.BtDeviceFoundStreamHandler
import com.devroom.niimbot_test.utils.PrintUtil
import com.gengcon.www.jcprintersdk.callback.Callback
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.mockito.Mock

class MainActivityTest {

    @Mock
    private lateinit var mockMainActivity: MainActivity

    @Mock
    private lateinit var mockMethodCall: MethodCall

    @Mock
    private lateinit var mockResult: MethodChannel.Result

    @Before
    fun setUp() {
        MockitoAnnotations.initMocks(this)
    }

    @After
    fun tearDown() {
        // Clean up test case
    }

    @Test
    fun testOnMethodCallWhenInitializeThenSuccess() {
        // Arrange
        Mockito.`when`(mockMethodCall.method).thenReturn("initialize")

        // Act
        mockMainActivity.onMethodCall(mockMethodCall, mockResult)

        // Assert
        Mockito.verify(mockMainActivity).initialize()
        Mockito.verify(mockResult).success(null)
    }

    @Test
    fun testOnMethodCallWhenScanPrintersThenSuccess() {
        // Arrange
        Mockito.`when`(mockMethodCall.method).thenReturn("scanPrinters")

        // Act
        mockMainActivity.onMethodCall(mockMethodCall, mockResult)

        // Assert
        Mockito.verify(mockMainActivity).scanPrinters()
        Mockito.verify(mockResult).success(null)
    }

    @Test
    fun testOnMethodCallWhenNonImplementedThenNotImplemented() {
        // Arrange
        Mockito.`when`(mockMethodCall.method).thenReturn("nonImplementedMethod")

        // Act
        mockMainActivity.onMethodCall(mockMethodCall, mockResult)

        // Assert
        Mockito.verify(mockResult).notImplemented()
    }
}