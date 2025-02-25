import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:projet_sncf/screen/liste_rapports_screen.dart';
import 'package:projet_sncf/utils/app_colors.dart';

void main() {
  initializeDateFormatting('fr_FR', null).then(
    (_) => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projet SNCF',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
        ),
        cardTheme: const CardTheme(
          color: AppColors.primary,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
        ),
        cardTheme: const CardTheme(
          color: AppColors.cardColor,
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.checkboxSelectedFillColor
                : null,
          ),
          checkColor: WidgetStateProperty.all(AppColors.checkboxCheckColor),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.radioSelectedFillColor
                : null,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const ListeRapportsScreen(),
    );
  }
}
