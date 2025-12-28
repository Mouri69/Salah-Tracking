import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prayer_record.dart';
import '../models/prayer_status.dart';

class PrayerWidget extends StatelessWidget {
  final PrayerRecord prayer;
  final VoidCallback onTap;

  const PrayerWidget({
    super.key,
    required this.prayer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = prayer.status.color;
    final timeFormat = DateFormat('hh:mm a');
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    prayer.prayerName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(prayer.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Time: ${timeFormat.format(prayer.prayerTime)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (prayer.performedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Performed: ${timeFormat.format(prayer.performedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(PrayerStatus status) {
    switch (status) {
      case PrayerStatus.notPrayed:
        return 'Not Prayed';
      case PrayerStatus.prayedOnTime:
        return 'On Time';
      case PrayerStatus.prayedLate:
        return 'Late';
    }
  }
}

