import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'features/refill/refill_provider.dart';
import 'features/refill/screens/refill_screen.dart';
import 'features/refill/screens/item_form_screen.dart';
import 'features/convention/convention_provider.dart';
import 'features/convention/screens/conventions_screen.dart';
import 'features/convention/screens/convention_detail_screen.dart';
import 'features/convention/screens/convention_form_screen.dart';
import 'features/analytics/screens/analytics_screen.dart';
import 'features/settings/screens/settings_screen.dart';

// ── Locale notifier ───────────────────────────────────────────────────────────

class LocaleNotifier extends ChangeNotifier {
  Locale _locale;
  static const _prefKey = 'app_locale';

  LocaleNotifier(Locale initial) : _locale = initial;

  Locale get locale => _locale;

  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  static Future<LocaleNotifier> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey) ?? 'en';
    return LocaleNotifier(Locale(code));
  }
}

// ── Router ────────────────────────────────────────────────────────────────────

final _router = GoRouter(
  initialLocation: '/refill',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _ScaffoldWithNavBar(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/refill',
            builder: (context, state) => const RefillScreen(),
            routes: [
              GoRoute(
                path: 'item/new',
                builder: (context, state) => const ItemFormScreen(),
              ),
              GoRoute(
                path: 'item/:id',
                builder: (context, state) => ItemFormScreen(
                  itemId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/convention',
            builder: (context, state) => const ConventionsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const ConventionFormScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => ConventionDetailScreen(
                  conventionId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => ConventionFormScreen(
                      conventionId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ]),
         StatefulShellBranch(routes: [
           GoRoute(
             path: '/analytics',
             builder: (context, state) => AnalyticsScreen(),
           ),
         ]),
         StatefulShellBranch(routes: [
           GoRoute(
             path: '/settings',
             builder: (context, state) => const SettingsScreen(),
           ),
         ]),
      ],
    ),
  ],
);

// ── Bottom navigation shell ───────────────────────────────────────────────────

class _ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ScaffoldWithNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // Recharger le stock quand on revient sur l'onglet Refill
          if (index == 0) {
            context.read<RefillProvider>().loadItems();
          }
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        destinations: [
           NavigationDestination(
             icon: const Icon(Icons.inventory_2_outlined),
             selectedIcon: const Icon(Icons.inventory_2),
             label: l10n.modeRefill,
           ),
           NavigationDestination(
             icon: const Icon(Icons.store_outlined),
             selectedIcon: const Icon(Icons.store),
             label: l10n.modeConvention,
           ),
           NavigationDestination(
             icon: const Icon(Icons.bar_chart_outlined),
             selectedIcon: const Icon(Icons.bar_chart),
             label: 'Analytics',
           ),
           NavigationDestination(
             icon: const Icon(Icons.settings_outlined),
             selectedIcon: const Icon(Icons.settings),
             label: l10n.modeSettings,
           ),
         ],
      ),
    );
  }
}

// ── App root ──────────────────────────────────────────────────────────────────

class ConventionApp extends StatelessWidget {
  const ConventionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = context.watch<LocaleNotifier>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RefillProvider()),
        ChangeNotifierProvider(create: (_) => ConventionProvider()),
      ],
      child: MaterialApp.router(
        title: 'Convention App',
        theme: ThemeData(
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
        ),
        locale: localeNotifier.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _router,
      ),
    );
  }
}
