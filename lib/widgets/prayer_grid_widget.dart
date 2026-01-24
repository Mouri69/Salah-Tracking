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
    if (prayers.isEmpty) return const SizedBox.shrink();

    // If we have exactly 5 prayers, we use a special layout:
    // Row 1: 2 prayers
    // Row 2: 3 prayers
    // This ensures no prayer is left alone.
    if (prayers.length == 5) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First Row: 2 items
              Row(
                children: [
                  Expanded(child: _buildPrayerItem(0)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildPrayerItem(1)),
                ],
              ),
              const SizedBox(height: 10),
              // Second Row: 3 items
              Row(
                children: [
                  Expanded(child: _buildPrayerItem(2)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildPrayerItem(3)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildPrayerItem(4)),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Fallback for other counts (though it should always be 5)
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(prayers.length, (index) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 42) / 2, // Approx half width
          child: _buildPrayerItem(index),
        );
      }),
    );
  }

  Widget _buildPrayerItem(int index) {
    return _PrayerCard(
      prayer: prayers[index],
      onTap: () => onPrayerTap(index),
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    prayer.status.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
