import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tax_calc/screens/it_data_entry_screen.dart';

// ── Brand Palette ─────────────────────────────────────────────────────────────
// Primary: Deep Indigo-Blue (trust, authority — like HDFC/SBI apps)
// Accent:  Teal-Green (positive, financial growth)
// Surface: Warm off-white (not clinical white — feels premium)

const Color kPrimary = Color(0xFF1A3C6E); // deep indigo blue
const Color kPrimaryLight = Color(0xFF2A5298); // medium blue
const Color kPrimaryDark = Color(0xFF0F2447); // darkest blue (appbar)
const Color kAccent = Color(0xFF00897B); // teal green (positive values)
const Color kAccentLight = Color(0xFFE0F2F1); // teal tint background
const Color kHighlight = Color(0xFFF57C00); // amber (TDS highlight)
const Color kHighlightBg = Color(0xFFFFF8EE); // amber tint
const Color kBackground = Color(0xFFF0F4F8); // cool light grey
const Color kSurface = Color(0xFFFFFFFF);
const Color kSurfaceAlt = Color(0xFFF7F9FC); // zebra row, section header
const Color kBorder = Color(0xFFDDE4EE);
const Color kBorderStrong = Color(0xFFB8C4D6);
const Color kTextPrimary = Color(0xFF0F1D35);
const Color kTextSecondary = Color(0xFF4A5568);
const Color kTextMuted = Color(0xFF8896AB);
const Color kError = Color(0xFFD32F2F);
const Color kSuccess = Color(0xFF00897B);
const Color kSuccessBg = Color(0xFFE0F2F1);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: kPrimaryDark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: kBackground,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const ItStatementApp());
}

class ItStatementApp extends StatelessWidget {
  const ItStatementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IT Statement 2026-27',
      theme: _buildTheme(),
      home: const ItDataEntryScreen(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        primary: kPrimary,
        secondary: kAccent,
        surface: kSurface,
        error: kError,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: kBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: kPrimaryDark,
        foregroundColor: kSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: kSurface,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: kSurface),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: kPrimaryDark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kError, width: 2),
        ),
        labelStyle: const TextStyle(
          color: kTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: const TextStyle(
          color: kPrimaryLight,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: const TextStyle(color: kError, fontSize: 11),
        prefixStyle: const TextStyle(
            color: kTextSecondary, fontSize: 14, fontWeight: FontWeight.w500),
        suffixStyle: const TextStyle(
            color: kTextSecondary, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: kSurface,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          side: const BorderSide(color: kPrimary, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      dividerTheme:
          const DividerThemeData(color: kBorder, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: kSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: kBorder),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
