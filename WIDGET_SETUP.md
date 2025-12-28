# Home Screen Widget Setup Guide

## Overview
This app now supports Android home screen widgets! You can add a widget to your home screen that displays your daily prayers and allows you to track them.

## How to Add the Widget to Your Home Screen

### Android:
1. **Long press** on your home screen
2. Tap **"Widgets"** from the menu
3. Scroll down and find **"Salah Tracking"** or **"Prayer Widget"**
4. **Long press** the widget and drag it to your home screen
5. Release to place it

### iOS:
iOS widget support requires additional setup with WidgetKit. This is more complex and requires:
- Creating a Widget Extension in Xcode
- Setting up App Groups
- Configuring the widget UI in SwiftUI

For now, the widget is primarily configured for Android.

## Widget Features

The widget displays:
- **Today's date**
- **Prayer completion counter** (e.g., "3/5")
- **All 5 prayers** in a 2-column grid:
  - Fajr
  - Dhuhr
  - Asr
  - Maghrib
  - Isha

Each prayer shows:
- Prayer name
- Prayer time
- Status badge (Not Prayed / On Time / Late)

## Interacting with the Widget

- **Tap any prayer** in the widget to open the app and mark that prayer
- The widget **automatically updates** when you mark prayers in the app
- Widget updates every 30 minutes automatically, or immediately when you update prayers in the app

## Technical Details

### Files Created:
- `lib/services/widget_service.dart` - Handles widget data updates
- `android/app/src/main/res/layout/prayer_widget.xml` - Widget layout
- `android/app/src/main/res/xml/prayer_widget_info.xml` - Widget configuration
- `android/app/src/main/kotlin/.../PrayerWidgetProvider.kt` - Widget provider

### Data Storage:
The widget reads data from SharedPreferences using the `home_widget` package, which stores data with the "flutter." prefix.

## Troubleshooting

If the widget doesn't appear:
1. Make sure you've **rebuilt the app** after adding the widget code
2. **Uninstall and reinstall** the app to ensure the widget provider is registered
3. Check that the widget appears in your widget picker
4. Try restarting your device

If the widget doesn't update:
1. Open the app and mark a prayer - this should trigger an update
2. Wait 30 minutes for the automatic update
3. Remove and re-add the widget to force a refresh

