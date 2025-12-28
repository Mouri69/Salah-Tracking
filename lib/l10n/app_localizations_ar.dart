// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تتبع الصلاة';

  @override
  String get todaysPrayers => 'صلاة اليوم';

  @override
  String get prayerHistory => 'سجل الصلاة';

  @override
  String get fajr => 'الفجر';

  @override
  String get dhuhr => 'الظهر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get isha => 'العشاء';

  @override
  String get notPrayed => 'لم تصلي';

  @override
  String get prayedOnTime => 'في الوقت';

  @override
  String get prayedLate => 'متأخر';

  @override
  String prayersCompleted(int count) {
    return 'تمت $count صلاة';
  }

  @override
  String get locationAccessRequired => 'يتطلب الوصول إلى الموقع';

  @override
  String get enableLocationServices =>
      'يرجى تفعيل خدمات الموقع للحصول على أوقات الصلاة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get today => 'اليوم';

  @override
  String get week => 'الأسبوع';

  @override
  String get month => 'الشهر';

  @override
  String noPrayersRecorded(String date) {
    return 'لا توجد صلوات مسجلة لـ $date';
  }
}
