import 'package:flutter/material.dart';
import 'package:ayuprep/ui/styles/colors.dart';

enum AppTheme { Light, Dark }

final appThemeData = {
  AppTheme.Light: ThemeData(
      shadowColor: primaryColor.withOpacity(0.25),
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: pageBackgroundColor,
      backgroundColor: backgroundColor,
      canvasColor: canvasColor,
      colorScheme: ThemeData().colorScheme.copyWith(
            secondary: secondaryColor,
          )),
  AppTheme.Dark: ThemeData(
      shadowColor: darkPrimaryColor.withOpacity(0.25),
      brightness: Brightness.dark,
      primaryColor: darkPrimaryColor,
      scaffoldBackgroundColor: darkPageBackgroundColor,
      backgroundColor: darkBackgroundColor,
      canvasColor: darkCanvasColor,
      colorScheme: ThemeData().colorScheme.copyWith(
            brightness: Brightness.dark,
            secondary: darkSecondaryColor,
          )),
};
