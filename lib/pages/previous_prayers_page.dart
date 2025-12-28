import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/prayer_provider.dart';
import '../widgets/prayer_widget.dart';
import '../models/daily_prayers.dart';

class PreviousPrayersPage extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  
  const PreviousPrayersPage({super.key, this.onThemeToggle});

  @override
  State<PreviousPrayersPage> createState() => _PreviousPrayersPageState();
}

class _PreviousPrayersPageState extends State<PreviousPrayersPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _viewMode = 'Today'; // Today, Week, Month

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer History'),
        actions: [
          if (widget.onThemeToggle != null)
            IconButton(
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: widget.onThemeToggle,
              tooltip: 'Toggle theme',
            ),
        ],
      ),
      body: Consumer<PrayerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Counter Section
              _buildCounterSection(context, provider),
              
              // View Mode Selector
              _buildViewModeSelector(),
              
              // Calendar
              _buildCalendar(provider),
              
              // Prayer List
              Expanded(
                child: _buildPrayerList(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCounterSection(BuildContext context, PrayerProvider provider) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (_viewMode) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    final stats = provider.getPrayerStats(startDate, endDate);
    final expected = _viewMode == 'Today'
        ? 5
        : _viewMode == 'Week'
            ? 35
            : (now.day * 5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Column(
        children: [
          Text(
            'Prayers Completed',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${stats['completed']}/$expected',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            _viewMode,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['Today', 'Week', 'Month'].map((mode) {
          final isSelected = _viewMode == mode;
          return GestureDetector(
            onTap: () {
              setState(() {
                _viewMode = mode;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                mode,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendar(PrayerProvider provider) {
    return TableCalendar<DailyPrayers>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarFormat: CalendarFormat.month,
      eventLoader: (day) {
        return provider.allPrayers
            .where((p) => isSameDay(p.date, day))
            .toList();
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildPrayerList(BuildContext context, PrayerProvider provider) {
    DailyPrayers? selectedPrayers;

    // Find prayers for selected day
    try {
      selectedPrayers = provider.allPrayers.firstWhere(
        (p) => isSameDay(p.date, _selectedDay),
      );
    } catch (e) {
      // No prayers found for this day
    }

    if (selectedPrayers == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No prayers recorded for ${DateFormat('MMM d, y').format(_selectedDay)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          DateFormat('EEEE, MMMM d, y').format(selectedPrayers.date),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...selectedPrayers.prayers.asMap().entries.map((entry) {
          final index = entry.key;
          final prayer = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PrayerWidget(
              prayer: prayer,
              onTap: () {
                if (selectedPrayers != null) {
                  provider.updatePrayerStatus(
                    selectedPrayers.date,
                    index,
                  );
                }
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}

