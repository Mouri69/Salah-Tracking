import 'package:home_widget/home_widget.dart';
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
    if (dailyPrayers == null) return;

    final storageService = StorageService();
    final isDarkTheme = await storageService.getTheme();
    final languageCode = await storageService.getLanguage();
    
    final timeFormat = DateFormat('hh:mm a', languageCode);
    final dateFormat = DateFormat('MMM d', languageCode);

    // Prepare prayer data
    final prayers = dailyPrayers.prayers;
    
    // Save theme and language
    await HomeWidget.saveWidgetData<String>('is_dark_theme', isDarkTheme ? 'true' : 'false');
    await HomeWidget.saveWidgetData<String>('language_code', languageCode);
    
    // Update widget data
    await HomeWidget.saveWidgetData<String>('date', dateFormat.format(dailyPrayers.date));
    await HomeWidget.saveWidgetData<String>('completed', '${dailyPrayers.completedCount}');
    await HomeWidget.saveWidgetData<String>('total', '${dailyPrayers.totalCount}');

    // Save each prayer's data with translations
    final prayerNames = _getPrayerNames(languageCode);
    for (int i = 0; i < prayers.length && i < 5; i++) {
      final prayer = prayers[i];
      await HomeWidget.saveWidgetData<String>('prayer_${i}_name', prayerNames[i]);
      await HomeWidget.saveWidgetData<String>('prayer_${i}_time', timeFormat.format(prayer.prayerTime));
      await HomeWidget.saveWidgetData<String>('prayer_${i}_status', _getStatusText(prayer.status, languageCode));
      
      if (prayer.performedAt != null) {
        await HomeWidget.saveWidgetData<String>('prayer_${i}_performed', timeFormat.format(prayer.performedAt!));
      } else {
        await HomeWidget.saveWidgetData<String>('prayer_${i}_performed', '');
      }
    }

    // Update the widget
    await HomeWidget.updateWidget(
      androidName: _androidProviderName,
    );
  }

  static List<String> _getPrayerNames(String languageCode) {
    if (languageCode == 'ar') {
      return ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
    }
    return ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  }

  static String _getStatusText(PrayerStatus status, String languageCode) {
    if (languageCode == 'ar') {
      switch (status) {
        case PrayerStatus.notPrayed:
          return 'notPrayed';
        case PrayerStatus.prayedOnTime:
          return 'prayedOnTime';
        case PrayerStatus.prayedLate:
          return 'prayedLate';
      }
    }
    return status.name;
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

