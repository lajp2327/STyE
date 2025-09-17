import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _corporateBlue = Color(0xFF1F5AA6);
const Color _corporateOrange = Color(0xFFF08A24);
const Color _successGreen = Color(0xFF2EBA7C);

ThemeData _buildTheme(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;
  final ColorScheme baseScheme = ColorScheme.fromSeed(
    seedColor: _corporateBlue,
    brightness: brightness,
  );
  final ColorScheme colorScheme = baseScheme.copyWith(
    secondary: _corporateOrange,
    onSecondary: baseScheme.onSecondary,
    secondaryContainer: baseScheme.secondaryContainer,
    tertiary: _successGreen,
    onTertiary: Colors.white,
  );

  final TextTheme baseTextTheme = GoogleFonts.robotoTextTheme(
    isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
  );

  final TextTheme textTheme = baseTextTheme.copyWith(
    displayMedium: baseTextTheme.displayMedium?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    ),
    titleLarge: baseTextTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
    ),
    titleMedium: baseTextTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.5),
    labelLarge: baseTextTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
  );

  RoundedRectangleBorder rounded(double radius) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardTheme(
      margin: EdgeInsets.zero,
      shape: rounded(20),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      height: 72,
      elevation: 8,
      indicatorColor: colorScheme.primaryContainer,
      iconTheme: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        return IconThemeData(
          color: states.contains(MaterialState.selected)
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
          size: 26,
        );
      }),
      labelTextStyle: MaterialStateProperty.resolveWith(
        (Set<MaterialState> states) {
          final TextStyle? base = textTheme.labelMedium;
          return base?.copyWith(
            fontWeight:
                states.contains(MaterialState.selected) ? FontWeight.w700 : FontWeight.w500,
          );
        },
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    chipTheme: ChipThemeData(
      shape: rounded(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      labelStyle: textTheme.labelLarge,
      selectedColor: colorScheme.secondaryContainer,
      secondarySelectedColor: colorScheme.tertiaryContainer,
      side: BorderSide(color: colorScheme.outlineVariant),
      showCheckmark: false,
      brightness: brightness,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(const Size(80, 40)),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
        side: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return BorderSide(color: colorScheme.primary, width: 1.4);
          }
          return BorderSide(color: colorScheme.outlineVariant);
        }),
        textStyle: MaterialStateProperty.all(textTheme.labelLarge),
        shape: MaterialStateProperty.all(rounded(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor:
          colorScheme.surfaceVariant.withOpacity(isDark ? 0.28 : 0.12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: textTheme.bodyMedium,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 44),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: textTheme.labelLarge,
        shape: rounded(16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 44),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: textTheme.labelLarge,
        shape: rounded(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(64, 44),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        foregroundColor: colorScheme.primary,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: rounded(20),
      extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      extendedTextStyle: textTheme.labelLarge,
      iconSize: 26,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      shape: rounded(20),
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onInverseSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    bannerTheme: MaterialBannerThemeData(
      backgroundColor: colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w600,
      ),
    ),
    dialogTheme: DialogTheme(
      shape: rounded(24),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),
    listTileTheme: ListTileThemeData(
      shape: rounded(16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      tileColor: colorScheme.surface,
      iconColor: colorScheme.primary,
    ),
    dividerTheme: DividerThemeData(
      space: 1,
      thickness: 1,
      color: colorScheme.outlineVariant.withOpacity(0.6),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all(
        colorScheme.primary.withOpacity(0.4),
      ),
      radius: const Radius.circular(8),
    ),
  );
}

final ThemeData lightTheme = _buildTheme(Brightness.light);
final ThemeData darkTheme = _buildTheme(Brightness.dark);
