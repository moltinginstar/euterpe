import "package:euterpe/res/res.dart";
import "package:euterpe/services/store.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

final _systemUiOverlayStyleLightLight = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  systemNavigationBarColor: const ResColors(Store.themeValueLight).primaryColor,
  systemNavigationBarIconBrightness: Brightness.dark,
);
final _systemUiOverlayStyleDarkLight = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  systemNavigationBarColor: const ResColors(Store.themeValueLight).primaryColor,
  systemNavigationBarIconBrightness: Brightness.dark,
);
final _systemUiOverlayStyleDarkDark = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  systemNavigationBarColor: const ResColors(Store.themeValueDark).primaryColor,
  systemNavigationBarIconBrightness: Brightness.light,
);

SystemUiOverlayStyle getSystemUiOverlayStyle(
  Brightness brightness,
  bool isBottomNavigationBarVisible,
  bool isTopSnackbarVisible,
) {
  if (brightness == Brightness.light || isTopSnackbarVisible) {
    return _systemUiOverlayStyleLightLight;
  } else if (!isBottomNavigationBarVisible) {
    return _systemUiOverlayStyleDarkLight;
  } else {
    return _systemUiOverlayStyleDarkDark;
  }
}

ThemeMode getThemeModeFromThemeString(String theme) {
  switch (theme) {
    case Store.themeValueLight:
      return ThemeMode.light;
    case Store.themeValueDark:
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

String getThemeString(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? Store.themeValueLight
        : Store.themeValueDark;
