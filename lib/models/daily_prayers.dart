import 'prayer_record.dart';
import 'prayer_status.dart';

class DailyPrayers {
  final DateTime date;
  final List<PrayerRecord> prayers;

  DailyPrayers({
    required this.date,
    required this.prayers,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'prayers': prayers.map((p) => p.toJson()).toList(),
    };
  }

  factory DailyPrayers.fromJson(Map<String, dynamic> json) {
    return DailyPrayers(
      date: DateTime.parse(json['date']),
      prayers: (json['prayers'] as List)
          .map((p) => PrayerRecord.fromJson(p))
          .toList(),
    );
  }

  int get completedCount {
    return prayers
        .where((p) => p.status != PrayerStatus.notPrayed)
        .length;
  }

  int get totalCount => prayers.length;
}

