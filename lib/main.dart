import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/product_provider.dart';
import 'screens/home_screen.dart';
import 'widgets/product_card.dart';

void main() {
  runApp(const PastellaApp());
}

class PastellaApp extends StatelessWidget {
  const PastellaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pastella',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: pastelCream,
          colorScheme: ColorScheme.fromSeed(
            seedColor: pastelPurple,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: pastelCream,
            foregroundColor: pastelText,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: pastelPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
