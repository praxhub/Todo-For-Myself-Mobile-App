package com.example.todo_for_myself_mobile_app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        TodayTaskWidgetProvider.refreshAll(this)
    }
}
