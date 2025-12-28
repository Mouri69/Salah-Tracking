package com.example.salah_tracking

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService

class PrayerWidgetFactory(private val context: Context, intent: Intent) : RemoteViewsService.RemoteViewsFactory {
    override fun onCreate() {}
    override fun onDestroy() {}
    override fun onDataSetChanged() {}
    override fun getCount(): Int = 0
    override fun getViewAt(position: Int): RemoteViews? = null
    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 0
    override fun getItemId(position: Int): Long = 0
    override fun hasStableIds(): Boolean = false
}

