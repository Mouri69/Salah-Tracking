import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../models/daily_prayers.dart';
import '../models/prayer_status.dart';

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

    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('MMM d');

    // Prepare prayer data
    final prayers = dailyPrayers.prayers;
    
    // Update widget data
    await HomeWidget.saveWidgetData<String>('date', dateFormat.format(dailyPrayers.date));
    await HomeWidget.saveWidgetData<String>('completed', '${dailyPrayers.completedCount}');
    await HomeWidget.saveWidgetData<String>('total', '${dailyPrayers.totalCount}');

    // Save each prayer's data
    for (int i = 0; i < prayers.length && i < 5; i++) {
      final prayer = prayers[i];
      await HomeWidget.saveWidgetData<String>('prayer_${i}_name', prayer.prayerName);
      await HomeWidget.saveWidgetData<String>('prayer_${i}_time', timeFormat.format(prayer.prayerTime));
      await HomeWidget.saveWidgetData<String>('prayer_${i}_status', prayer.status.name);
      
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

