import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../services/storage_service.dart';
import '../services/widget_service.dart';
import '../models/daily_prayers.dart';
import '../models/prayer_status.dart';

class PrayerProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  final PrayerService _prayerService = PrayerService();
  final StorageService _storageService = StorageService();

  Position? _currentPosition;
  DailyPrayers? _todayPrayers;
  List<DailyPrayers> _allPrayers = [];
  bool _isLoading = false;

  Position? get currentPosition => _currentPosition;
  DailyPrayers? get todayPrayers => _todayPrayers;
  List<DailyPrayers> get allPrayers => _allPrayers;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get location
      _currentPosition = await _locationService.getCurrentLocation();
      
      // If no location, try to get from storage
      if (_currentPosition == null) {
        final savedLocation = await _storageService.getLocation();
        if (savedLocation != null) {
          _currentPosition = Position(
            latitude: savedLocation['latitude']!,
            longitude: savedLocation['longitude']!,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        }
      } else {
        // Save location for future use
        await _storageService.saveLocation(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }

      // Load today's prayers
      await loadTodayPrayers();
      
      // Load all prayers
      await loadAllPrayers();

      // Sync from widget to get latest status updates
      await syncFromWidget();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    
    // Update widget after initialization (separate from finally block to ensure it runs)
    print('PrayerProvider: Initialization complete. _todayPrayers is ${_todayPrayers != null ? "NOT null" : "NULL"}');
    if (_todayPrayers != null) {
      print('PrayerProvider: Calling WidgetService.updateWidget with ${_todayPrayers!.prayers.length} prayers');
      // Update widget immediately - don't delay
      try {
        await WidgetService.updateWidget(_todayPrayers);
        print('PrayerProvider: WidgetService.updateWidget completed successfully');
      } catch (e, stackTrace) {
        print('PrayerProvider: ERROR calling WidgetService.updateWidget: $e');
        print('PrayerProvider: Stack trace: $stackTrace');
      }
    } else {
      print('PrayerProvider: WARNING - _todayPrayers is null, cannot update widget!');
    }
  }

  Future<void> loadTodayPrayers() async {
    if (_currentPosition == null) return;

    final today = DateTime.now();
    final languageCode = await _storageService.getLanguage();
    final savedPrayers = await _storageService.getPrayersForDate(today);

    if (savedPrayers != null) {
      _todayPrayers = savedPrayers;
      // Update prayer names based on current language
      final prayerNames = _prayerService.getPrayerNames(languageCode);
      final updatedPrayers = _todayPrayers!.prayers.asMap().entries.map((entry) {
        final index = entry.key;
        final prayer = entry.value;
        return prayer.copyWith(prayerName: prayerNames[index]);
      }).toList();
      _todayPrayers = DailyPrayers(
        date: _todayPrayers!.date,
        prayers: updatedPrayers,
      );
      await _storageService.saveDailyPrayers(_todayPrayers!);
    } else {
      // Generate new prayers for today
      final prayers = _prayerService.getPrayersForDate(
        today,
        _currentPosition!,
        languageCode: languageCode,
      );
      _todayPrayers = DailyPrayers(
        date: today,
        prayers: prayers,
      );
      await _storageService.saveDailyPrayers(_todayPrayers!);
    }

    // Always update widget after loading prayers
    if (_todayPrayers != null) {
      print('PrayerProvider.loadTodayPrayers: Calling WidgetService.updateWidget with ${_todayPrayers!.prayers.length} prayers');
      try {
        await WidgetService.updateWidget(_todayPrayers);
        print('PrayerProvider.loadTodayPrayers: WidgetService.updateWidget completed successfully');
      } catch (e, stackTrace) {
        print('PrayerProvider.loadTodayPrayers: ERROR calling WidgetService.updateWidget: $e');
        print('PrayerProvider.loadTodayPrayers: Stack trace: $stackTrace');
      }
    } else {
      print('PrayerProvider.loadTodayPrayers: WARNING - _todayPrayers is null, cannot update widget!');
    }

    notifyListeners();
  }

  Future<void> loadAllPrayers() async {
    _allPrayers = await _storageService.getAllPrayers();
    notifyListeners();
  }

  Future<void> updatePrayerStatus(
    DateTime date,
    int prayerIndex,
  ) async {
    if (_currentPosition == null) return;

    final now = DateTime.now();
    final prayers = date.day == DateTime.now().day && date.month == DateTime.now().month && date.year == DateTime.now().year
        ? _todayPrayers
        : await _storageService.getPrayersForDate(date);

    if (prayers == null) return;

    final prayer = prayers.prayers[prayerIndex];
    final newStatus = prayer.status.next;

    final updatedPrayer = prayer.copyWith(
      status: newStatus,
      performedAt: newStatus != PrayerStatus.notPrayed ? now : null,
    );

    final updatedPrayers = prayers.prayers.toList();
    updatedPrayers[prayerIndex] = updatedPrayer;

    final updatedDailyPrayers = DailyPrayers(
      date: prayers.date,
      prayers: updatedPrayers,
    );

    await _storageService.saveDailyPrayers(updatedDailyPrayers);

    if (date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      _todayPrayers = updatedDailyPrayers;
    }
    
    // Always update widget when prayers change (only for today)
    if (_todayPrayers != null) {
      await WidgetService.updateWidget(_todayPrayers);
    }

    await loadAllPrayers();
    notifyListeners();
  }

  // Call this method to force sync from widget (can be called from anywhere)
  Future<void> forceSyncFromWidget() async {
    await syncFromWidget();
  }

  Map<String, int> getPrayerStats(DateTime startDate, DateTime endDate) {
    int total = 0;
    int completed = 0;

    for (var dailyPrayers in _allPrayers) {
      if (dailyPrayers.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          dailyPrayers.date.isBefore(endDate.add(const Duration(days: 1)))) {
        total += dailyPrayers.totalCount;
        completed += dailyPrayers.completedCount;
      }
    }

    return {'total': total, 'completed': completed};
  }

  // Sync widget changes back to Flutter
  Future<void> syncFromWidget() async {
    if (_todayPrayers == null) return;
    
    try {
      // Read widget data from SharedPreferences (home_widget stores with "flutter." prefix)
      final prefs = await SharedPreferences.getInstance();
      
      // Check if any prayer status changed in widget
      bool hasChanges = false;
      final updatedPrayers = _todayPrayers!.prayers.toList();
      
      for (int i = 0; i < updatedPrayers.length && i < 5; i++) {
        // home_widget stores data with "flutter." prefix in FlutterSharedPreferences
        final widgetStatus = prefs.getString('flutter.prayer_${i}_status');
        if (widgetStatus != null) {
          PrayerStatus? newStatus;
          switch (widgetStatus) {
            case 'notPrayed':
              newStatus = PrayerStatus.notPrayed;
              break;
            case 'prayedOnTime':
              newStatus = PrayerStatus.prayedOnTime;
              break;
            case 'prayedLate':
              newStatus = PrayerStatus.prayedLate;
              break;
          }
          
          if (newStatus != null && updatedPrayers[i].status != newStatus) {
            final performedAtStr = prefs.getString('flutter.prayer_${i}_performed');
            DateTime? performedAt;
            if (performedAtStr != null && performedAtStr.isNotEmpty) {
              try {
                // Parse the time format from widget (hh:mm a)
                final format = DateFormat('hh:mm a');
                final time = format.parse(performedAtStr);
                performedAt = DateTime(
                  _todayPrayers!.date.year,
                  _todayPrayers!.date.month,
                  _todayPrayers!.date.day,
                  time.hour,
                  time.minute,
                );
              } catch (e) {
                // If parsing fails, use current time
                performedAt = DateTime.now();
              }
            }
            
            updatedPrayers[i] = updatedPrayers[i].copyWith(
              status: newStatus,
              performedAt: newStatus != PrayerStatus.notPrayed ? (performedAt ?? DateTime.now()) : null,
            );
            hasChanges = true;
          }
        }
      }
      
      if (hasChanges) {
        print('PrayerProvider.syncFromWidget: Has changes, updating prayers...');
        _todayPrayers = DailyPrayers(
          date: _todayPrayers!.date,
          prayers: updatedPrayers,
        );
        await _storageService.saveDailyPrayers(_todayPrayers!);
        await loadAllPrayers();
        
        // Update widget with new status
        await WidgetService.updateWidget(_todayPrayers);
        
        notifyListeners();
        print('PrayerProvider.syncFromWidget: Changes synced and UI updated');
      } else {
        print('PrayerProvider.syncFromWidget: No changes detected');
      }
    } catch (e, stackTrace) {
      print('PrayerProvider.syncFromWidget: ERROR: $e');
      print('PrayerProvider.syncFromWidget: Stack trace: $stackTrace');
    }
  }
}

