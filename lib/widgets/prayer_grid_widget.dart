import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prayer_record.dart';
import '../models/prayer_status.dart';

class PrayerGridWidget extends StatelessWidget {
  final List<PrayerRecord> prayers;
  final Function(int index) onPrayerTap;

  const PrayerGridWidget({
    super.key,
    required this.prayers,
    required this.onPrayerTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: prayers.length,
      itemBuilder: (context, index) {
        final prayer = prayers[index];
        return _PrayerCard(
          prayer: prayer,
          onTap: () => onPrayerTap(index),
        );
      },
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final PrayerRecord prayer;
  final VoidCallback onTap;

  const _PrayerCard({
    required this.prayer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = prayer.status.color;
    final timeFormat = DateFormat('hh:mm a');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: statusColor,
            width: 2.5,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                statusColor.withOpacity(0.15),
                statusColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Prayer Name
                Text(
                  prayer.prayerName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                
                // Prayer Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        timeFormat.format(prayer.prayerTime),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getStatusText(prayer.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
                
                // Performed Time (if available)
                if (prayer.performedAt != null) ...[
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      timeFormat.format(prayer.performedAt!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 8,
                            color: isDark ? Colors.grey[500] : Colors.grey[700],
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
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

