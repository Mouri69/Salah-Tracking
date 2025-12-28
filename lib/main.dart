import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'providers/prayer_provider.dart';
import 'services/storage_service.dart';
import 'services/widget_service.dart';
import 'pages/today_prayers_page.dart';
import 'pages/previous_prayers_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;
  Locale _locale = const Locale('en');
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeWidget();
  }

  Future<void> _initializeWidget() async {
    await WidgetService.initialize();
  }

  Future<void> _loadSettings() async {
    final isDark = await _storageService.getTheme();
    final languageCode = await _storageService.getLanguage();
    setState(() {
      _isDarkTheme = isDark;
      _locale = Locale(languageCode);
    });
  }

  void _toggleTheme() async {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
    await _storageService.saveTheme(_isDarkTheme);
    // Update widget with new theme immediately
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<PrayerProvider>(context, listen: false);
      if (provider.todayPrayers != null) {
        await WidgetService.updateWidget(provider.todayPrayers);
      }
    });
  }

  void _changeLanguage(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    await _storageService.saveLanguage(locale.languageCode);
    // Update widget with new language immediately
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<PrayerProvider>(context, listen: false);
      await provider.loadTodayPrayers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PrayerProvider()..initialize(),
      child: MaterialApp(
        title: 'Salah Tracking',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
        ],
        home: MainScreen(
          isDarkTheme: _isDarkTheme,
          currentLocale: _locale,
          onThemeToggle: _toggleTheme,
          onLanguageChange: _changeLanguage,
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isDarkTheme;
  final Locale currentLocale;
  final VoidCallback onThemeToggle;
  final Function(Locale) onLanguageChange;

  const MainScreen({
    super.key,
    required this.isDarkTheme,
    required this.currentLocale,
    required this.onThemeToggle,
    required this.onLanguageChange,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    TodayPrayersPage(
      onThemeToggle: widget.onThemeToggle,
      onLanguageChange: widget.onLanguageChange,
      currentLocale: widget.currentLocale,
    ),
    PreviousPrayersPage(
      onThemeToggle: widget.onThemeToggle,
      onLanguageChange: widget.onLanguageChange,
      currentLocale: widget.currentLocale,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today),
            label: "Today's Prayers",
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
