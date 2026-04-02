import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: Color(0xFF6366F1),
        primaryContainer: Color(0xFFE0E7FF),
        secondary: Color(0xFF8B5CF6),
        secondaryContainer: Color(0xFFEDE9FE),
        tertiary: Color(0xFF06B6D4),
        tertiaryContainer: Color(0xFFCFFAFE),
        error: Color(0xFFEF4444),
        errorContainer: Color(0xFFFEE2E2),
      ),
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 4,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 6,
        blendOnColors: false,
        useM2StyleDividerInM3: false,
        defaultRadius: 12.0,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12.0,
        inputDecoratorUnfocusedHasBorder: false,
        inputDecoratorFocusedHasBorder: true,
        inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
        inputDecoratorBackgroundAlpha: 12,
        chipRadius: 20.0,
        cardRadius: 16.0,
        cardElevation: 0,
        dialogRadius: 20.0,
        dialogElevation: 3,
        popupMenuRadius: 12.0,
        popupMenuElevation: 4,
        appBarBackgroundSchemeColor: SchemeColor.surface,
        appBarScrolledUnderElevation: 0.5,
        bottomNavigationBarElevation: 0,
        navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
        navigationBarIndicatorOpacity: 1.0,
        drawerRadius: 20.0,
        filledButtonRadius: 12.0,
        elevatedButtonRadius: 12.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        toggleButtonsRadius: 12.0,
        segmentedButtonRadius: 12.0,
        switchThumbSchemeColor: SchemeColor.onPrimary,
        checkboxSchemeColor: SchemeColor.primary,
        tooltipRadius: 8,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
    ).copyWith(
      dividerTheme: const DividerThemeData(
        thickness: 0.5,
        space: 0.5,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: Color(0xFF818CF8),
        primaryContainer: Color(0xFF312E81),
        secondary: Color(0xFFA78BFA),
        secondaryContainer: Color(0xFF4C1D95),
        tertiary: Color(0xFF22D3EE),
        tertiaryContainer: Color(0xFF164E63),
        error: Color(0xFFF87171),
        errorContainer: Color(0xFF7F1D1D),
      ),
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 15,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 25,
        blendOnColors: true,
        useM2StyleDividerInM3: false,
        defaultRadius: 12.0,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12.0,
        inputDecoratorUnfocusedHasBorder: false,
        inputDecoratorFocusedHasBorder: true,
        inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
        inputDecoratorBackgroundAlpha: 22,
        chipRadius: 20.0,
        cardRadius: 16.0,
        cardElevation: 0,
        dialogRadius: 20.0,
        dialogElevation: 6,
        popupMenuRadius: 12.0,
        popupMenuElevation: 8,
        appBarBackgroundSchemeColor: SchemeColor.surface,
        appBarScrolledUnderElevation: 0.5,
        bottomNavigationBarElevation: 0,
        navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
        navigationBarIndicatorOpacity: 1.0,
        drawerRadius: 20.0,
        filledButtonRadius: 12.0,
        elevatedButtonRadius: 12.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        toggleButtonsRadius: 12.0,
        segmentedButtonRadius: 12.0,
        switchThumbSchemeColor: SchemeColor.onPrimary,
        checkboxSchemeColor: SchemeColor.primary,
        tooltipRadius: 8,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
    ).copyWith(
      dividerTheme: const DividerThemeData(
        thickness: 0.5,
        space: 0.5,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
