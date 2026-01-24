import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/prayer_provider.dart';
import '../widgets/prayer_grid_widget.dart';

class TodayPrayersPage extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final Function(Locale)? onLanguageChange;
  final Locale? currentLocale;
  
  const TodayPrayersPage({
    super.key,
    this.onThemeToggle,
    this.onLanguageChange,
    this.currentLocale,
  });

  @override
  State<TodayPrayersPage> createState() => _TodayPrayersPageState();
}

class _TodayPrayersPageState extends State<TodayPrayersPage> {
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PrayerProvider>();
      provider.syncFromWidget();
      _syncTimer?.cancel();
      _syncTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        provider.syncFromWidget();
      });
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Prayers"),
        actions: [
          // Language switcher
          if (widget.onLanguageChange != null && widget.currentLocale != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.language),
              tooltip: 'Change language',
              onSelected: (value) {
                widget.onLanguageChange!(Locale(value));
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'en',
                  child: Row(
                    children: [
                      if (widget.currentLocale!.languageCode == 'en')
                        const Icon(Icons.check, size: 20),
                      const SizedBox(width: 8),
                      const Text('English'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'ar',
                  child: Row(
                    children: [
                      if (widget.currentLocale!.languageCode == 'ar')
                        const Icon(Icons.check, size: 20),
                      const SizedBox(width: 8),
                      const Text('العربية'),
                    ],
                  ),
                ),
              ],
            ),
          // Theme toggle
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PrayerProvider>().initialize();
            },
          ),
        ],
      ),
      body: Consumer<PrayerProvider>(
        builder: (context, provider, child) {
          // Sync from widget when this page is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.syncFromWidget();
          });
          
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.currentPosition == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Location access required',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please enable location services to get prayer times',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      provider.initialize();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.todayPrayers == null) {
            return const Center(child: Text('No prayers available'));
          }

          final prayers = provider.todayPrayers!.prayers;
          final dateFormat = DateFormat('EEEE, MMMM d, y');

          return RefreshIndicator(
            onRefresh: () => provider.initialize(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text(
                              dateFormat.format(provider.todayPrayers!.date),
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${provider.todayPrayers!.completedCount}/${provider.todayPrayers!.totalCount} Prayers Completed',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrayerGridWidget(
                    prayers: prayers,
                    onPrayerTap: (index) {
                      provider.updatePrayerStatus(
                        provider.todayPrayers!.date,
                        index,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

