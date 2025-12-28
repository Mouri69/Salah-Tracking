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
        
        // Handle prayer click - update status directly
        if (intent.action == "UPDATE_PRAYER_STATUS") {
            val prayerIndex = intent.getIntExtra("prayer_index", -1)
            if (prayerIndex >= 0 && prayerIndex < 5) {
                updatePrayerStatus(context, prayerIndex)
            }
        }
        
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, PrayerWidgetProvider::class.java)
            )
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }
    
    private fun updatePrayerStatus(context: Context, prayerIndex: Int) {
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
        
        // Update widget immediately
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(
            android.content.ComponentName(context, PrayerWidgetProvider::class.java)
        )
        onUpdate(context, appWidgetManager, appWidgetIds)
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        
        val views = RemoteViews(context.packageName, R.layout.prayer_widget)
        
        // Update date
        val date = prefs.getString("flutter.date", "Today") ?: "Today"
        views.setTextViewText(R.id.widget_date, date)
        
        // Update counter
        val completed = prefs.getString("flutter.completed", "0") ?: "0"
        val total = prefs.getString("flutter.total", "5") ?: "5"
        views.setTextViewText(R.id.widget_counter, "$completed/$total")
        
        // Update each prayer
        for (i in 0..4) {
            val name = prefs.getString("flutter.prayer_${i}_name", getPrayerName(i)) ?: getPrayerName(i)
            val time = prefs.getString("flutter.prayer_${i}_time", "") ?: ""
            val status = prefs.getString("flutter.prayer_${i}_status", "notPrayed") ?: "notPrayed"
            
            val nameId = context.resources.getIdentifier("prayer_${i}_name", "id", context.packageName)
            val timeId = context.resources.getIdentifier("prayer_${i}_time", "id", context.packageName)
            val statusId = context.resources.getIdentifier("prayer_${i}_status", "id", context.packageName)
            
            if (nameId != 0) views.setTextViewText(nameId, name)
            if (timeId != 0) views.setTextViewText(timeId, time)
            
            if (statusId != 0) {
                val statusText = getStatusText(status)
                val statusColor = getStatusColor(status)
                views.setTextViewText(statusId, statusText)
                views.setInt(statusId, "setBackgroundColor", statusColor)
            }
            
            // Update background drawable based on status
            val cardLayoutId = context.resources.getIdentifier("prayer_$i", "id", context.packageName)
            if (cardLayoutId != 0) {
                val backgroundRes = when (status) {
                    "prayedOnTime" -> R.drawable.prayer_card_background_green
                    "prayedLate" -> R.drawable.prayer_card_background_yellow
                    else -> R.drawable.prayer_card_background_gray
                }
                views.setInt(cardLayoutId, "setBackgroundResource", backgroundRes)
                
                // Set click intent to update status directly (no app opening)
                val clickIntent = Intent(context, PrayerWidgetProvider::class.java).apply {
                    action = "UPDATE_PRAYER_STATUS"
                    putExtra("prayer_index", i)
                }
                views.setOnClickPendingIntent(
                    cardLayoutId,
                    android.app.PendingIntent.getBroadcast(context, i, clickIntent, android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE)
                )
            }
        }
        
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
    
    private fun getPrayerName(index: Int): String {
        return when (index) {
            0 -> "Fajr"
            1 -> "Dhuhr"
            2 -> "Asr"
            3 -> "Maghrib"
            4 -> "Isha"
            else -> ""
        }
    }
    
    private fun getStatusText(status: String): String {
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

