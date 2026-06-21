import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/pace_selector/domain/entities/pace_entity.dart';

class AppTheme {
  
  static const Color primaryTeal = Color.fromARGB(255, 45, 202, 194); 
  static const Color backgroundDark = Color(0xFF050812);
  static const Color backgroundCard = Color.fromARGB(255, 19, 31, 58);
  static const Color textWhite = Colors.white;

  
  static const Color textGrey = Color(0xFF64748B);
  static const Color textSlate = Color(0xFF475569);
  static const Color tickGrey = Color(0xFF334155);
  static const Color borderGrey = Color(0x14FFFFFF); 

  
  static const Color colorElite = Color(0xFFda9224); 
  static const Color colorAdvanced = Color.fromARGB(
    255,
    87,
    129,
    163,
  ); 
  static const Color colorIntermediate = Color.fromARGB(
    255,
    45,
    202,
    194,
  ); 
  static const Color colorBeginner = Color.fromARGB(255, 137, 152, 173); 

  static Color getLevelColor(SwimmerLevel level) {
    switch (level) {
      case SwimmerLevel.elite:
        return colorElite;
      case SwimmerLevel.advanced:
        return colorAdvanced;
      case SwimmerLevel.intermediate:
        return colorIntermediate;
      case SwimmerLevel.beginner:
        return colorBeginner;
    }
  }

  
  static TextStyle get titleLarge => GoogleFonts.outfit(
    color: textWhite,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle get subtitle =>
      GoogleFonts.inter(color: textGrey, fontSize: 15, height: 1.4);

  static TextStyle get labelSmall => GoogleFonts.inter(
    color: textGrey,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
  );

  static TextStyle get paceNumberStyle => GoogleFonts.atkinsonHyperlegibleMono(
    color: textWhite,
    fontSize: 110,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.0,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.dark,
        surface: backgroundDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
      ),
    );
  }
}
