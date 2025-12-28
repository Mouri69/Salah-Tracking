import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../services/storage_service.dart';
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodayPrayers() async {
    if (_currentPosition == null) return;

    final today = DateTime.now();
    final savedPrayers = await _storageService.getPrayersForDate(today);

    if (savedPrayers != null) {
      _todayPrayers = savedPrayers;
    } else {
      // Generate new prayers for today
      final prayers = _prayerService.getPrayersForDate(
        today,
        _currentPosition!,
      );
      _todayPrayers = DailyPrayers(
        date: today,
        prayers: prayers,
      );
      await _storageService.saveDailyPrayers(_todayPrayers!);
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

    await loadAllPrayers();
    notifyListeners();
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
}

