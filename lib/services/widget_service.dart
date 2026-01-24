import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/daily_prayers.dart';
import '../models/prayer_status.dart';
import '../services/storage_service.dart';

class WidgetService {
  static const String _androidProviderName = 'PrayerWidgetProvider';

  // Initialize the widget service
  static Future<void> initialize() async {
    try {
      // For iOS, you need an App Group. For Android, this is optional.
      // await HomeWidget.setAppGroupId('group.salah.tracking');
    } catch (e) {
      // App Group might not be set up, that's okay for Android
    }
  }

  // Update widget with today's prayer data
  static Future<void> updateWidget(DailyPrayers? dailyPrayers) async {
    print('WidgetService: updateWidget called with dailyPrayers: ${dailyPrayers != null}');
    if (dailyPrayers == null) {
      print('WidgetService: updateWidget called with null dailyPrayers - ABORTING');
      return;
    }

    try {
      print('WidgetService: Starting widget update...');
      final storageService = StorageService();
      final isDarkTheme = await storageService.getTheme();
      final languageCode = await storageService.getLanguage();
      
      print('WidgetService: Theme: $isDarkTheme, Language: $languageCode');
      
      final timeFormat = DateFormat('hh:mm a', languageCode);
      final dateFormat = DateFormat('MMM d', languageCode);

      // Prepare prayer data
      final prayers = dailyPrayers.prayers;
      
      print('WidgetService: Updating widget with ${prayers.length} prayers');
      
      // Save theme and language
      await HomeWidget.saveWidgetData<String>('is_dark_theme', isDarkTheme ? 'true' : 'false');
      await HomeWidget.saveWidgetData<String>('language_code', languageCode);
      
      // Update widget data
      await HomeWidget.saveWidgetData<String>('date', dateFormat.format(dailyPrayers.date));
      await HomeWidget.saveWidgetData<String>('completed', '${dailyPrayers.completedCount}');
      await HomeWidget.saveWidgetData<String>('total', '${dailyPrayers.totalCount}');

      // Save each prayer's data with translations
      // Use the actual prayer names from the prayer records (they're already translated)
      for (int i = 0; i < prayers.length && i < 5; i++) {
        final prayer = prayers[i];
        // Use the prayer name directly from the record (it's already in the correct language)
        final prayerName = prayer.prayerName;
        final prayerTime = timeFormat.format(prayer.prayerTime);
        final prayerStatus = prayer.status.name;
        
        // Save all prayer data - make sure to save even if empty
        // IMPORTANT: Save as String explicitly and verify the save succeeded
        try {
          // Save using home_widget
          await HomeWidget.saveWidgetData<String>('prayer_${i}_name', prayerName);
          await HomeWidget.saveWidgetData<String>('prayer_${i}_time', prayerTime);
          await HomeWidget.saveWidgetData<String>('prayer_${i}_status', prayerStatus);
          
          if (prayer.performedAt != null) {
            await HomeWidget.saveWidgetData<String>('prayer_${i}_performed', timeFormat.format(prayer.performedAt!));
          } else {
            await HomeWidget.saveWidgetData<String>('prayer_${i}_performed', '');
          }
          
          // ALSO save directly to SharedPreferences as backup (home_widget uses FlutterSharedPreferences)
          // This ensures the data is definitely saved even if home_widget has issues
          final prefs = await SharedPreferences.getInstance();
          // NOTE: SharedPreferences plugin adds 'flutter.' prefix automatically to keys.
          // We want the final key in XML to be 'flutter.prayer_${i}_name', so we should use 'prayer_${i}_name' here.
          await prefs.setString('prayer_${i}_name', prayerName);
          await prefs.setString('prayer_${i}_time', prayerTime);
          await prefs.setString('prayer_${i}_status', prayerStatus);
          if (prayer.performedAt != null) {
            await prefs.setString('prayer_${i}_performed', timeFormat.format(prayer.performedAt!));
          } else {
            await prefs.setString('prayer_${i}_performed', '');
          }
          
          print('WidgetService: Saved prayer $i - name: "$prayerName", time: "$prayerTime", status: "$prayerStatus"');
          
          // Verify the save by reading it back
          // When reading with SharedPreferences plugin, we use the same key (plugin handles prefix)
          final savedTime = prefs.getString('prayer_${i}_time') ?? '';
          print('WidgetService: Verified saved time for prayer $i: "$savedTime" (expected: "$prayerTime")');
          
          if (savedTime != prayerTime) {
            print('WidgetService: WARNING - Saved time does not match! Expected: "$prayerTime", Got: "$savedTime"');
          } else {
            print('WidgetService: SUCCESS - Prayer $i time saved correctly!');
          }
        } catch (e, stackTrace) {
          print('WidgetService: ERROR saving prayer $i data: $e');
          print('WidgetService: Stack trace: $stackTrace');
        }
      }
    } catch (e) {
      print('WidgetService: Error updating widget: $e');
      rethrow;
    }

    // Wait a moment to ensure all data is committed to SharedPreferences
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Update the widget - force update
    try {
      await HomeWidget.updateWidget(
        androidName: _androidProviderName,
      );
      // Also try to force update all widgets
      await HomeWidget.updateWidget(
        androidName: _androidProviderName,
        qualifiedAndroidName: 'com.example.salah_tracking.PrayerWidgetProvider',
      );
    } catch (e) {
      // If qualified name fails, that's okay
      await HomeWidget.updateWidget(
        androidName: _androidProviderName,
      );
    }
    
    print('WidgetService: Widget update completed');
  }


  // Get status color name for widget
  static String getStatusColor(PrayerStatus status) {
    switch (status) {
      case PrayerStatus.notPrayed:
        return 'gray';
      case PrayerStatus.prayedOnTime:
        return 'green';
      case PrayerStatus.prayedLate:
        return 'yellow';
    }
  }
}

