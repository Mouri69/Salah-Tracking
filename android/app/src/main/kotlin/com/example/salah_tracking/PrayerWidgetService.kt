package com.example.salah_tracking

import android.content.Intent
import android.widget.RemoteViewsService

class PrayerWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsService.RemoteViewsFactory {
        return PrayerWidgetFactory(applicationContext, intent)
    }
}

