import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../models/prayer_record.dart';

class PrayerService {
  static const List<String> prayerNames = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  List<PrayerRecord> getPrayersForDate(DateTime date, Position position) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = CalculationParameters(
      fajrAngle: 18.0,
      ishaAngle: 17.0,
    );
    
    // Convert DateTime to DateComponents for the specific date
    final dateComponents = DateComponents.from(date);
    
    // Get prayer times for the specific date
    final datePrayerTimes = PrayerTimes(coordinates, dateComponents, params);
    
    return [
      PrayerRecord(
        prayerName: prayerNames[0],
        prayerTime: datePrayerTimes.fajr,
      ),
      PrayerRecord(
        prayerName: prayerNames[1],
        prayerTime: datePrayerTimes.dhuhr,
      ),
      PrayerRecord(
        prayerName: prayerNames[2],
        prayerTime: datePrayerTimes.asr,
      ),
      PrayerRecord(
        prayerName: prayerNames[3],
        prayerTime: datePrayerTimes.maghrib,
      ),
      PrayerRecord(
        prayerName: prayerNames[4],
        prayerTime: datePrayerTimes.isha,
      ),
    ];
  }

  bool isPrayerOnTime(DateTime prayerTime, DateTime performedAt) {
    // Consider prayer on time if performed within 30 minutes after prayer time
    final difference = performedAt.difference(prayerTime);
    return difference.inMinutes <= 30 && difference.inMinutes >= 0;
  }
}

