package com.devroom.niimbot_test.utils


import android.app.Application
import android.content.Context
import com.gengcon.www.jcprintersdk.JCPrintApi
import com.gengcon.www.jcprintersdk.callback.Callback


class PrintUtil private constructor(context: Context, callback: Callback) {

    companion object {
        private lateinit var _instance: PrintUtil

        fun initialize(context: Context, callback: Callback) {
            synchronized(this) {
                if (!::_instance.isInitialized) {
                    _instance = PrintUtil(context, callback)
                }
            }
        }

        val instance: JCPrintApi
            get() {
                return _instance.api!!
            }
    }


    private var api: JCPrintApi? = null

    init {
        if (api == null) {
            api = JCPrintApi.getInstance(callback)
            api!!.init(context.applicationContext as Application)
            api!!.initImageProcessingDefault("", "")
        }
    }

//    val instance: JCPrintApi?
//        get() {
//            if (api == null) {
//                api = JCPrintApi.getInstance(CALLBACK)
//
////                api!!.init(MyApplication.getInstance())
//                api!!.initImageProcessingDefault("", "")
//
//            }
//            return api
//        }

//    private const val TAG = "PrintUtil"

//    private fun getApi(context: Context): JCPrintApi {
//        if (api == null) {
//            api = JCPrintApi.getInstance(CALLBACK)
//            api!!.init(context.applicationContext as Application)
//            api!!.initImageProcessingDefault("", "")
//        }
//        return api!!
//    }

//    fun openPrinter(context: Context, address: String?): Int {
////        ImageParam().width
////        JcImageSdkApi.getVersion()
//
//        if (api == null) {
//            api = JCPrintApi.getInstance(CALLBACK)
//            api!!.init(context.applicationContext as Application)
//            api!!.initImageProcessingDefault("", "")
//        }
//        return api!!.openPrinterByAddress(address)
//    }
//
//    fun close(context: Context) {
//        val api = getApi(context)
//        api.close()
//    }
//
//    fun isConnected(context: Context): Int {
//        return getApi(context).isConnection
//    }

}
