// [Presentation Layer] — 앱 전체 테마 담당
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 따뜻한 다이어리 컬러 팔레트
  static const Color warmCream = Color(0xFFFDF6EC);
  static const Color warmBeige = Color(0xFFEDE0CC);
  static const Color warmBorder = Color(0xFFDFCDB8);
  static const Color primary = Color(0xFFB87A50); // 따뜻한 테라코타
  static const Color primaryLight = Color(0xFFF2E4D4);
  static const Color textDark = Color(0xFF3D2B1F);
  static const Color textMedium = Color(0xFF7A5C45);
  static const Color textLight = Color(0xFFAA8C75);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: warmCream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: primary,
          surface: Colors.white,
          onPrimary: Colors.white,
        ),

        // 기본 폰트
        textTheme: GoogleFonts.notoSansTextTheme().copyWith(
          bodyLarge: GoogleFonts.notoSans(color: textDark, fontSize: 15),
          bodyMedium: GoogleFonts.notoSans(color: textMedium, fontSize: 13),
          bodySmall: GoogleFonts.notoSans(color: textLight, fontSize: 12),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: warmCream,
          foregroundColor: textDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.gaegu(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          iconTheme: const IconThemeData(color: textDark),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: GoogleFonts.notoSans(color: textMedium, fontSize: 14),
          hintStyle: GoogleFonts.notoSans(color: textLight, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: warmBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: warmBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: warmBorder),
          ),
          margin: EdgeInsets.zero,
        ),
      );
}
