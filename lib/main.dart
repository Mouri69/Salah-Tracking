import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/prayer_provider.dart';
import 'services/storage_service.dart';
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
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await _storageService.getTheme();
    setState(() {
      _isDarkTheme = isDark;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
    _storageService.saveTheme(_isDarkTheme);
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
        home: MainScreen(
          isDarkTheme: _isDarkTheme,
          onThemeToggle: _toggleTheme,
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isDarkTheme;
  final VoidCallback onThemeToggle;

  const MainScreen({
    super.key,
    required this.isDarkTheme,
    required this.onThemeToggle,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    TodayPrayersPage(onThemeToggle: widget.onThemeToggle),
    PreviousPrayersPage(onThemeToggle: widget.onThemeToggle),
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
