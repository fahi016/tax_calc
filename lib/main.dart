import 'package:flutter/material.dart';
import 'package:tax_calc/screens/it_data_entry_screen.dart';

void main() {
  runApp(const ItStatementApp());
}

class ItStatementApp extends StatelessWidget {
  const ItStatementApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF1A237E);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HB's TAX CALCULATOR 2026-27",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      home: const ItDataEntryScreen(),
    );
  }
}
