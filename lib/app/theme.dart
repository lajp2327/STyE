import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _corporateBlue = Color(0xFF005BAC);
const Color _corporateOrange = Color(0xFFF36E21);

ThemeData _buildTheme(Brightness brightness) {
  final Color seed = brightness == Brightness.dark
      ? _corporateBlue.withOpacity(0.8)
      : _corporateBlue;
  final ColorScheme baseScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
  );
  final ColorScheme colorScheme = baseScheme.copyWith(
    secondary: _corporateOrange,
    onSecondary: baseScheme.onSecondary,
    secondaryContainer: baseScheme.secondaryContainer,
  );
  final TextTheme textTheme = GoogleFonts.robotoTextTheme();

  RoundedRectangleBorder roundedShape(double radius) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    visualDensity: VisualDensity.comfortable,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    ),
    cardTheme: CardTheme(
      shape: roundedShape(16),
      elevation: 2,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: colorScheme.secondaryContainer,
      labelTextStyle: MaterialStateProperty.resolveWith((
        Set<MaterialState> states,
      ) {
        final TextStyle? base = textTheme.labelMedium;
        return base?.copyWith(
          fontWeight: states.contains(MaterialState.selected)
              ? FontWeight.w600
              : FontWeight.w500,
        );
      }),
      backgroundColor: colorScheme.surface,
      elevation: 8,
    ),
    chipTheme: ChipThemeData(
      shape: roundedShape(16),
      labelStyle: textTheme.labelLarge,
      side: BorderSide(color: colorScheme.outlineVariant),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(roundedShape(16)),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        textStyle: MaterialStateProperty.all(
          textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: textTheme.bodyMedium,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        shape: roundedShape(16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        shape: roundedShape(16),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: roundedShape(16),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      extendedIconLabelSpacing: 12,
    ),
    dialogTheme: DialogTheme(
      shape: roundedShape(20),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: textTheme.bodyMedium,
    ),
    bannerTheme: MaterialBannerThemeData(
      backgroundColor: colorScheme.secondaryContainer,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

final ThemeData lightTheme = _buildTheme(Brightness.light);
final ThemeData darkTheme = _buildTheme(Brightness.dark);
