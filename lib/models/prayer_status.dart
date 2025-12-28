import 'package:flutter/material.dart';

enum PrayerStatus {
  notPrayed, // Default/null - didn't pray or clicked by mistake
  prayedOnTime, // Green - prayed on time
  prayedLate, // Yellow - prayed but late
}

extension PrayerStatusExtension on PrayerStatus {
  Color get color {
    switch (this) {
      case PrayerStatus.notPrayed:
        return Colors.grey;
      case PrayerStatus.prayedOnTime:
        return Colors.green;
      case PrayerStatus.prayedLate:
        return Colors.yellow;
    }
  }
  
  PrayerStatus get next {
    switch (this) {
      case PrayerStatus.notPrayed:
        return PrayerStatus.prayedOnTime;
      case PrayerStatus.prayedOnTime:
        return PrayerStatus.prayedLate;
      case PrayerStatus.prayedLate:
        return PrayerStatus.notPrayed;
    }
  }
}

