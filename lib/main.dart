import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'core/theme/app_theme.dart';
import 'cubit/building_cubit.dart';
import 'cubit/building_state.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'services/building_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.isSupabaseConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey, // ignore: deprecated_member_use
    );
  }

  runApp(const AmaratyApp());
}

class AmaratyApp extends StatelessWidget {
  const AmaratyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BuildingCubit(BuildingService())..loadData(),
      child: BlocBuilder<BuildingCubit, BuildingState>(
        builder: (context, state) {
          return MaterialApp(
            title: state.s.appTitle,
            debugShowCheckedModeBanner: false,
            locale: Locale(state.localeCode),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            builder: (context, child) {
              if (!AppConfig.isStaging || child == null) {
                return child ?? const SizedBox.shrink();
              }
              return Banner(
                message: 'STAGING',
                location: BannerLocation.topStart,
                color: const Color(0xFFEA580C),
                textStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: Colors.white,
                ),
                child: child,
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
