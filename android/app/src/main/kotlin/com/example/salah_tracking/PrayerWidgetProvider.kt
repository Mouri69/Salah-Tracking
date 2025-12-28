package com.example.salah_tracking

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.example.salah_tracking.R

class PrayerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        try {
            // Handle prayer click - update status directly
            if (intent.action == "com.example.salah_tracking.UPDATE_PRAYER_STATUS" || 
                intent.action == "UPDATE_PRAYER_STATUS") {
                val prayerIndex = intent.getIntExtra("prayer_index", -1)
                if (prayerIndex >= 0 && prayerIndex < 5) {
                    updatePrayerStatus(context, prayerIndex)
                }
                return
            }
            
            if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(
                    android.content.ComponentName(context, PrayerWidgetProvider::class.java)
                )
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        } catch (e: Exception) {
            android.util.Log.e("PrayerWidget", "Error in onReceive: ${e.message}", e)
        }
    }
    
    private fun updatePrayerStatus(context: Context, prayerIndex: Int) {
        try {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val currentStatus = prefs.getString("flutter.prayer_${prayerIndex}_status", "notPrayed") ?: "notPrayed"
        
        // Cycle through statuses: notPrayed -> prayedOnTime -> prayedLate -> notPrayed
        val newStatus = when (currentStatus) {
            "notPrayed" -> "prayedOnTime"
            "prayedOnTime" -> "prayedLate"
            "prayedLate" -> "notPrayed"
            else -> "notPrayed"
        }
        
        // Save new status
        val editor = prefs.edit()
        editor.putString("flutter.prayer_${prayerIndex}_status", newStatus)
        
        // Update performed time if prayed
        if (newStatus != "notPrayed") {
            val timeFormat = java.text.SimpleDateFormat("hh:mm a", java.util.Locale.getDefault())
            val currentTime = timeFormat.format(java.util.Date())
            editor.putString("flutter.prayer_${prayerIndex}_performed", currentTime)
        } else {
            editor.putString("flutter.prayer_${prayerIndex}_performed", "")
        }
        
        // Update counter
        var completed = 0
        for (i in 0..4) {
            val status = prefs.getString("flutter.prayer_${i}_status", "notPrayed") ?: "notPrayed"
            if (i == prayerIndex) {
                if (newStatus != "notPrayed") completed++
            } else {
                if (status != "notPrayed") completed++
            }
        }
        editor.putString("flutter.completed", completed.toString())
        editor.apply()
        
        // Update widget immediately - force refresh with new colors
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(
            android.content.ComponentName(context, PrayerWidgetProvider::class.java)
        )
        // Call updateAppWidget directly for each widget to ensure colors update
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
        } catch (e: Exception) {
            android.util.Log.e("PrayerWidget", "Error updating prayer status: ${e.message}", e)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        try {
            // home_widget stores data in FlutterSharedPreferences with specific key format
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            
            val views = RemoteViews(context.packageName, R.layout.prayer_widget)
            
            // Get theme and language - home_widget stores as "flutter.keyName" in SharedPreferences
            // The home_widget package stores data with "flutter." prefix
            val isDarkThemeStr = prefs.getString("flutter.is_dark_theme", "false") ?: "false"
            val isDarkTheme = isDarkThemeStr == "true"
            val languageCode = prefs.getString("flutter.language_code", "en") ?: "en"
            
            android.util.Log.d("PrayerWidget", "Theme: $isDarkTheme, Language: $languageCode")
            
            // Set widget background based on theme
            try {
                val rootId = R.id.widget_root
                val backgroundColor = if (isDarkTheme) 0xFF1E1E1E.toInt() else 0xFFFFFFFF.toInt()
                views.setInt(rootId, "setBackgroundColor", backgroundColor)
            } catch (e: Exception) {
                android.util.Log.e("PrayerWidget", "Error setting background: ${e.message}")
                // Continue without setting background if it fails
            }
            
            // Update counter
            try {
                val completed = prefs.getString("flutter.completed", "0") ?: "0"
                val total = prefs.getString("flutter.total", "5") ?: "5"
                views.setTextViewText(R.id.widget_counter, "$completed/$total")
                
                // Set counter text color based on theme
                val counterColor = if (isDarkTheme) 0xFF64B5F6.toInt() else 0xFF2196F3.toInt()
                views.setTextColor(R.id.widget_counter, counterColor)
            } catch (e: Exception) {
                android.util.Log.e("PrayerWidget", "Error updating counter: ${e.message}")
            }
            
            // Update each prayer
            for (i in 0..4) {
            // Read prayer data - home_widget stores with "flutter." prefix
            // The home_widget package stores String values with "flutter.keyName" format
            val name = prefs.getString("flutter.prayer_${i}_name", null) ?: getPrayerName(i, languageCode)
            val time = prefs.getString("flutter.prayer_${i}_time", null) ?: ""
            val status = prefs.getString("flutter.prayer_${i}_status", null) ?: "notPrayed"
            
            android.util.Log.d("PrayerWidget", "Prayer $i: name=$name, time=$time, status=$status")
            
            try {
                val nameId = context.resources.getIdentifier("prayer_${i}_name", "id", context.packageName)
                val timeId = context.resources.getIdentifier("prayer_${i}_time", "id", context.packageName)
                val statusId = context.resources.getIdentifier("prayer_${i}_status", "id", context.packageName)
                
                if (nameId != 0) {
                    views.setTextViewText(nameId, name)
                    // Set text color based on theme
                    val textColor = if (isDarkTheme) 0xFFFFFFFF.toInt() else 0xFF000000.toInt()
                    views.setTextColor(nameId, textColor)
                }
                if (timeId != 0) {
                    views.setTextViewText(timeId, time)
                    val timeColor = if (isDarkTheme) 0xFFB0B0B0.toInt() else 0xFF666666.toInt()
                    views.setTextColor(timeId, timeColor)
                }
                
                if (statusId != 0) {
                    val statusText = getStatusText(status, languageCode)
                    val statusColor = getStatusColor(status)
                    views.setTextViewText(statusId, statusText)
                    views.setInt(statusId, "setBackgroundColor", statusColor)
                }
                
                // Update background drawable based on status and theme
                val cardLayoutId = context.resources.getIdentifier("prayer_$i", "id", context.packageName)
                if (cardLayoutId != 0) {
                    val backgroundRes = when {
                        status == "prayedOnTime" && isDarkTheme -> R.drawable.prayer_card_background_dark_green
                        status == "prayedOnTime" && !isDarkTheme -> R.drawable.prayer_card_background_green
                        status == "prayedLate" && isDarkTheme -> R.drawable.prayer_card_background_dark_yellow
                        status == "prayedLate" && !isDarkTheme -> R.drawable.prayer_card_background_yellow
                        isDarkTheme -> R.drawable.prayer_card_background_dark
                        else -> R.drawable.prayer_card_background_gray
                    }
                    views.setInt(cardLayoutId, "setBackgroundResource", backgroundRes)
                    
                    // Set click intent to update status directly (no app opening)
                    try {
                        val clickIntent = Intent(context, PrayerWidgetProvider::class.java).apply {
                            action = "com.example.salah_tracking.UPDATE_PRAYER_STATUS"
                            putExtra("prayer_index", i)
                        }
                        views.setOnClickPendingIntent(
                            cardLayoutId,
                            android.app.PendingIntent.getBroadcast(
                                context, 
                                i, 
                                clickIntent, 
                                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                            )
                        )
                    } catch (e: Exception) {
                        android.util.Log.e("PrayerWidget", "Error setting click intent for prayer $i: ${e.message}")
                    }
                }
            } catch (e: Exception) {
                android.util.Log.e("PrayerWidget", "Error updating prayer $i: ${e.message}")
            }
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (e: Exception) {
            android.util.Log.e("PrayerWidget", "Error updating widget: ${e.message}", e)
        }
    }
    
    private fun getPrayerName(index: Int, languageCode: String = "en"): String {
        if (languageCode == "ar") {
            return when (index) {
                0 -> "الفجر"
                1 -> "الظهر"
                2 -> "العصر"
                3 -> "المغرب"
                4 -> "العشاء"
                else -> ""
            }
        }
        return when (index) {
            0 -> "Fajr"
            1 -> "Dhuhr"
            2 -> "Asr"
            3 -> "Maghrib"
            4 -> "Isha"
            else -> ""
        }
    }
    
    private fun getStatusText(status: String, languageCode: String = "en"): String {
        if (languageCode == "ar") {
            return when (status) {
                "prayedOnTime" -> "في الوقت"
                "prayedLate" -> "متأخر"
                else -> "لم تصلي"
            }
        }
        return when (status) {
            "prayedOnTime" -> "On Time"
            "prayedLate" -> "Late"
            else -> "Not Prayed"
        }
    }
    
    private fun getStatusColor(status: String): Int {
        return when (status) {
            "prayedOnTime" -> 0xFF4CAF50.toInt() // Green
            "prayedLate" -> 0xFFFFEB3B.toInt() // Yellow
            else -> 0xFF9E9E9E.toInt() // Gray
        }
    }
}

