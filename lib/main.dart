import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tax_calc/screens/it_data_entry_screen.dart';

// ── Brand tokens ──────────────────────────────────────────────────────────────
const Color kNavy = Color(0xFF0A1931);
const Color kNavyLight = Color(0xFF162944);
const Color kGold = Color(0xFFC9A84C);
const Color kGoldLight = Color(0xFFE2C97E);
const Color kBackground = Color(0xFFF4F6FA);
const Color kSurface = Color(0xFFFFFFFF);
const Color kBorder = Color(0xFFDDE1EA);
const Color kTextPrimary = Color(0xFF0A1931);
const Color kTextSecondary = Color(0xFF5A6478);
const Color kTextMuted = Color(0xFF8C95A6);
const Color kError = Color(0xFFBF3030);
const Color kSuccess = Color(0xFF1A6B3A);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: kNavy,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ItStatementApp());
}

class ItStatementApp extends StatelessWidget {
  const ItStatementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Income Tax Calculator 2026-27',
      theme: _buildTheme(),
      home: const ItDataEntryScreen(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: kNavy,
        primary: kNavy,
        secondary: kGold,
        surface: kSurface,
        error: kError,
      ),
      scaffoldBackgroundColor: kBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: kNavy,
        foregroundColor: kSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: kSurface,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: kSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: kNavy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: kError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: kError, width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: kTextSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: kNavy,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: const TextStyle(color: kError, fontSize: 11),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kNavy,
          foregroundColor: kSurface,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kNavy,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          side: const BorderSide(color: kNavy, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ),
      dividerTheme:
          const DividerThemeData(color: kBorder, thickness: 1, space: 1),
    );
  }
}
