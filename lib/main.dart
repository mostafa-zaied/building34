import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'cubit/building_cubit.dart';
import 'cubit/building_state.dart';
import 'l10n/app_localizations.dart';
import 'screens/main_shell.dart';
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
            theme: ThemeData.light(useMaterial3: true).copyWith(
              scaffoldBackgroundColor: const Color(0xFFF1F5F9),
              cardColor: Colors.white,
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF4F46E5),
                secondary: Color(0xFF16A34A),
                surface: Colors.white,
              ),
            ),
            darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              cardColor: const Color(0xFF1E293B),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF6366F1),
                secondary: Color(0xFF22C55E),
                surface: Color(0xFF1E293B),
              ),
            ),
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
