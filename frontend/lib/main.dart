import 'package:flutter/material.dart';

import 'features/auth/screens/onboarding_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<Color> primaryColorNotifier = ValueNotifier(const Color(0xFF007BFF));

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: primaryColorNotifier,
      builder: (_, color, __) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (_, mode, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Gawee',
              themeMode: mode,
              // SETTING TEMA TERANG
              theme: ThemeData(
                useMaterial3: false, 
                brightness: Brightness.light,
                primaryColor: color,
                scaffoldBackgroundColor: const Color(0xFFF4F5FA),
                cardColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.black),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.black87),
                  bodyMedium: TextStyle(color: Colors.black54),
                ),
                colorScheme: ColorScheme.light(primary: color),
              ),
              // SETTING TEMA GELAP
              darkTheme: ThemeData(
                useMaterial3: false, // WAJIB MATI
                brightness: Brightness.dark,
                primaryColor: color,
                scaffoldBackgroundColor: const Color(0xFF121212),
                cardColor: const Color(0xFF1E1E1E),
                iconTheme: const IconThemeData(color: Colors.white),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.white),
                  bodyMedium: TextStyle(color: Colors.white70),
                ),
                colorScheme: ColorScheme.dark(primary: color),
              ),
              home: const OnboardingScreen(), 
            );
          },
        );
      },
    );
  }
}