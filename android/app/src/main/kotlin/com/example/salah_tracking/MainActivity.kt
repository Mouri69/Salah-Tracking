package com.example.salah_tracking

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "salah_tracking/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "syncWidgetData") {
                // Widget data is already in SharedPreferences, Flutter can read it
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Check if app was opened from widget update
        if (intent.getBooleanExtra("widget_prayer_updated", false)) {
            val prayerIndex = intent.getIntExtra("prayer_index", -1)
            // Data is already saved in SharedPreferences by widget
            // Flutter will read it on next load
        }
    }
}
