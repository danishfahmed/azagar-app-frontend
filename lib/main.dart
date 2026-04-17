import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/theme/app_theme_controller.dart';
import 'package:azager/core/services/session_manager.dart';
import 'package:azager/modules/shared/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager.init();
  AppThemeController.setDarkMode(SessionManager.isDarkMode);
  runApp(const MyApp());
}

ThemeData _buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    brightness: Brightness.light,
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.scaffold,
    canvasColor: AppColors.scaffold,
    cardColor: Colors.white,
    dividerColor: const Color(0xFFECECEC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.textSecondary,
      textColor: AppColors.textPrimary,
    ),
    iconTheme: const IconThemeData(color: AppColors.textSecondary),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.35);
        }
        return const Color(0xFFD6D6D6);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: AppColors.textHint),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.fieldBorder),
      ),
    ),
  );
}

ThemeData _buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    brightness: Brightness.dark,
  );

  const darkSurface = Color(0xFF161616);
  const darkCard = Color(0xFF1E1E1E);

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: darkSurface,
    canvasColor: darkSurface,
    cardColor: darkCard,
    dividerColor: const Color(0xFF2B2B2B),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.white70,
      textColor: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return Colors.white70;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.45);
        }
        return const Color(0xFF3A3A3A);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      hintStyle: const TextStyle(color: Colors.white54),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Azager',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          home: const SplashScreen(),
        );
      },
    );
  }
}
