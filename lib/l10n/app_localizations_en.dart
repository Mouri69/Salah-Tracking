// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Salah Tracking';

  @override
  String get todaysPrayers => 'Today\'s Prayers';

  @override
  String get prayerHistory => 'Prayer History';

  @override
  String get fajr => 'Fajr';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get notPrayed => 'Not Prayed';

  @override
  String get prayedOnTime => 'On Time';

  @override
  String get prayedLate => 'Late';

  @override
  String prayersCompleted(int count) {
    return '$count Prayers Completed';
  }

  @override
  String get locationAccessRequired => 'Location access required';

  @override
  String get enableLocationServices =>
      'Please enable location services to get prayer times';

  @override
  String get retry => 'Retry';

  @override
  String get today => 'Today';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String noPrayersRecorded(String date) {
    return 'No prayers recorded for $date';
  }
}
