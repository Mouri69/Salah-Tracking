import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_prayers.dart';

class StorageService {
  static const String _prayersKey = 'daily_prayers';
  static const String _themeKey = 'is_dark_theme';
  static const String _locationKey = 'last_location';
  static const String _languageKey = 'language_code';

  Future<void> saveDailyPrayers(DailyPrayers dailyPrayers) async {
    final prefs = await SharedPreferences.getInstance();
    final allPrayers = await getAllPrayers();
    
    // Remove existing entry for the same date
    allPrayers.removeWhere(
      (p) => _isSameDay(p.date, dailyPrayers.date),
    );
    
    // Add the new entry
    allPrayers.add(dailyPrayers);
    
    // Save to storage
    final jsonList = allPrayers.map((p) => p.toJson()).toList();
    await prefs.setString(_prayersKey, jsonEncode(jsonList));
  }

  Future<DailyPrayers?> getPrayersForDate(DateTime date) async {
    final allPrayers = await getAllPrayers();
    try {
      return allPrayers.firstWhere(
        (p) => _isSameDay(p.date, date),
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<DailyPrayers>> getAllPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prayersKey);
    
    if (jsonString == null) {
      return [];
    }
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => DailyPrayers.fromJson(json))
        .toList();
  }

  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<void> saveLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('${_locationKey}_lat', latitude);
    await prefs.setDouble('${_locationKey}_lng', longitude);
  }

  Future<Map<String, double>?> getLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('${_locationKey}_lat');
    final lng = prefs.getDouble('${_locationKey}_lng');
    
    if (lat != null && lng != null) {
      return {'latitude': lat, 'longitude': lng};
    }
    return null;
  }

  Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

