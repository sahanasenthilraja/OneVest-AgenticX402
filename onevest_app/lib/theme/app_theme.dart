import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ============================================================
  // ONEVEST COLORS
  // ============================================================

  static const Color background =
      Color(0xFF020B1D);

  static const Color panel =
      Color(0xFF0E1830);

  static const Color panelLight =
      Color(0xFF111F36);

  static const Color border =
      Color(0xFF263A56);

  static const Color teal =
      Color(0xFF14C8B0);

  static const Color tealDark =
      Color(0xFF0C3942);

  static const Color white =
      Color(0xFFF5F8FC);

  static const Color muted =
      Color(0xFF91A0B8);

  // ============================================================
  // ONEVEST DARK THEME
  // ============================================================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor:
        background,

    colorScheme: const ColorScheme.dark(
      primary: teal,
      secondary: teal,
      surface: panel,
      onPrimary: background,
      onSecondary: background,
      onSurface: white,
    ),

    // ==========================================================
    // TYPOGRAPHY
    // ==========================================================

    textTheme:
        GoogleFonts.spaceMonoTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      displayLarge:
          GoogleFonts.pressStart2p(
        color: white,
        fontSize: 22,
      ),

      displayMedium:
          GoogleFonts.pressStart2p(
        color: white,
        fontSize: 18,
      ),

      displaySmall:
          GoogleFonts.pressStart2p(
        color: white,
        fontSize: 15,
      ),

      headlineLarge:
          GoogleFonts.pressStart2p(
        color: white,
        fontSize: 18,
      ),

      headlineMedium:
          GoogleFonts.pressStart2p(
        color: white,
        fontSize: 14,
      ),

      headlineSmall:
          GoogleFonts.pressStart2p(
        color: white,
        fontSize: 11,
      ),

      titleLarge:
          GoogleFonts.spaceMono(
        color: white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),

      titleMedium:
          GoogleFonts.spaceMono(
        color: white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),

      titleSmall:
          GoogleFonts.spaceMono(
        color: muted,
        fontSize: 11,
      ),

      bodyLarge:
          GoogleFonts.spaceMono(
        color: white,
        fontSize: 13,
      ),

      bodyMedium:
          GoogleFonts.spaceMono(
        color: muted,
        fontSize: 11,
      ),

      bodySmall:
          GoogleFonts.spaceMono(
        color: muted,
        fontSize: 9,
      ),

      labelLarge:
          GoogleFonts.spaceMono(
        color: white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),

      labelMedium:
          GoogleFonts.spaceMono(
        color: muted,
        fontSize: 9,
      ),

      labelSmall:
          GoogleFonts.spaceMono(
        color: muted,
        fontSize: 8,
      ),
    ),

    // ==========================================================
    // APP BAR
    // ==========================================================

    appBarTheme: AppBarTheme(
      backgroundColor:
          background,

      surfaceTintColor:
          Colors.transparent,

      elevation: 0,

      scrolledUnderElevation: 0,

      centerTitle: false,

      iconTheme:
          const IconThemeData(
        color: white,
        size: 22,
      ),

      titleTextStyle:
          GoogleFonts.pressStart2p(
        color: white,
        fontSize: 12,
      ),
    ),

    // ==========================================================
    // CARDS
    // ==========================================================

    cardTheme: CardThemeData(
      color: panel,

      elevation: 0,

      shadowColor:
          Colors.transparent,

      margin:
          const EdgeInsets.all(0),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),

        side: const BorderSide(
          color: border,
          width: 1,
        ),
      ),
    ),

    // ==========================================================
    // INPUT FIELDS
    // ==========================================================

    inputDecorationTheme:
        InputDecorationTheme(
      filled: true,

      fillColor: panel,

      hintStyle:
          GoogleFonts.spaceMono(
        color: muted,
        fontSize: 11,
      ),

      labelStyle:
          GoogleFonts.spaceMono(
        color: muted,
        fontSize: 11,
      ),

      floatingLabelStyle:
          GoogleFonts.spaceMono(
        color: teal,
        fontSize: 11,
      ),

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            const BorderSide(
          color: border,
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            const BorderSide(
          color: border,
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            const BorderSide(
          color: teal,
          width: 1.5,
        ),
      ),

      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            const BorderSide(
          color: Colors.redAccent,
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    ),

    // ==========================================================
    // ELEVATED BUTTON
    // ==========================================================

    elevatedButtonTheme:
        ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
        backgroundColor: teal,

        foregroundColor:
            background,

        elevation: 0,

        minimumSize:
            const Size(
          double.infinity,
          52,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 15,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),

        textStyle:
            GoogleFonts.spaceMono(
          fontSize: 11,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    ),

    // ==========================================================
    // OUTLINED BUTTON
    // ==========================================================

    outlinedButtonTheme:
        OutlinedButtonThemeData(
      style:
          OutlinedButton.styleFrom(
        foregroundColor: teal,

        minimumSize:
            const Size(
          double.infinity,
          52,
        ),

        side:
            const BorderSide(
          color: teal,
          width: 1,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),

        textStyle:
            GoogleFonts.spaceMono(
          fontSize: 10,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    ),

    // ==========================================================
    // TEXT BUTTON
    // ==========================================================

    textButtonTheme:
        TextButtonThemeData(
      style:
          TextButton.styleFrom(
        foregroundColor: teal,

        textStyle:
            GoogleFonts.spaceMono(
          fontSize: 10,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    ),

    // ==========================================================
    // CHECKBOX
    // ==========================================================

    checkboxTheme:
        CheckboxThemeData(
      checkColor:
          WidgetStateProperty.all(
        background,
      ),

      fillColor:
          WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(
            WidgetState.selected,
          )) {
            return teal;
          }

          return Colors.transparent;
        },
      ),

      side:
          const BorderSide(
        color: border,
      ),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(5),
      ),
    ),

    // ==========================================================
    // SWITCH
    // ==========================================================

    switchTheme:
        SwitchThemeData(
      thumbColor:
          WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(
            WidgetState.selected,
          )) {
            return teal;
          }

          return muted;
        },
      ),

      trackColor:
          WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(
            WidgetState.selected,
          )) {
            return teal.withValues(
              alpha: 0.25,
            );
          }

          return border;
        },
      ),
    ),

    // ==========================================================
    // DIVIDER
    // ==========================================================

    dividerTheme:
        const DividerThemeData(
      color: border,
      thickness: 1,
      space: 1,
    ),

    // ==========================================================
    // ICONS
    // ==========================================================

    iconTheme:
        const IconThemeData(
      color: white,
      size: 22,
    ),

    // ==========================================================
    // SNACKBAR
    // ==========================================================

    snackBarTheme:
        SnackBarThemeData(
      backgroundColor: panelLight,

      contentTextStyle:
          GoogleFonts.spaceMono(
        color: white,
        fontSize: 10,
      ),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),

      behavior:
          SnackBarBehavior.floating,
    ),
  );
}
