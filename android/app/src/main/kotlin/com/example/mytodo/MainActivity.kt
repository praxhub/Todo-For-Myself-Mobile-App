package com.example.mytodo

import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.finpilot.ai/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getRecentSms") {
                val smsList = readRecentSms()
                result.success(smsList)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun readRecentSms(): List<String> {
        val lstSms = ArrayList<String>()
        val uri = Uri.parse("content://sms/inbox")
        val cursor = contentResolver.query(uri, arrayOf("body", "date"), null, null, "date DESC LIMIT 50")
        
        cursor?.use {
            if (it.moveToFirst()) {
                val bodyIndex = it.getColumnIndex("body")
                val dateIndex = it.getColumnIndex("date")
                
                do {
                    val body = it.getString(bodyIndex)
                    val dateStr = it.getString(dateIndex)
                    // Format output simply as "DATE||BODY" so dart can split it
                    lstSms.add("$dateStr||$body")
                } while (it.moveToNext())
            }
        }
        return lstSms
    }
}
