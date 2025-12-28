import 'prayer_status.dart';

class PrayerRecord {
  final String prayerName;
  final DateTime prayerTime;
  final DateTime? performedAt;
  final PrayerStatus status;

  PrayerRecord({
    required this.prayerName,
    required this.prayerTime,
    this.performedAt,
    this.status = PrayerStatus.notPrayed,
  });

  Map<String, dynamic> toJson() {
    return {
      'prayerName': prayerName,
      'prayerTime': prayerTime.toIso8601String(),
      'performedAt': performedAt?.toIso8601String(),
      'status': status.name,
    };
  }

  factory PrayerRecord.fromJson(Map<String, dynamic> json) {
    return PrayerRecord(
      prayerName: json['prayerName'],
      prayerTime: DateTime.parse(json['prayerTime']),
      performedAt: json['performedAt'] != null
          ? DateTime.parse(json['performedAt'])
          : null,
      status: PrayerStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PrayerStatus.notPrayed,
      ),
    );
  }

  PrayerRecord copyWith({
    String? prayerName,
    DateTime? prayerTime,
    DateTime? performedAt,
    PrayerStatus? status,
  }) {
    return PrayerRecord(
      prayerName: prayerName ?? this.prayerName,
      prayerTime: prayerTime ?? this.prayerTime,
      performedAt: performedAt ?? this.performedAt,
      status: status ?? this.status,
    );
  }
}

