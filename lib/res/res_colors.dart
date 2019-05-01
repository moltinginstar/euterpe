import "package:euterpe/services/store.dart";
import "package:flutter/material.dart";

class ResColors {
  final String _theme;

  static const _colors = {
    "primaryColor": {
      Store.themeValueLight: Colors.white,
      Store.themeValueDark: Colors.black,
    },
    "secondaryColor": {
      Store.themeValueLight: Colors.white,
      Store.themeValueDark: Colors.white,
    },
    "colorOnSecondary": {
      Store.themeValueLight: Colors.black,
      Store.themeValueDark: Colors.black,
    },
    "accentColor": {
      Store.themeValueLight: Colors.black,
      Store.themeValueDark: Colors.white,
    },
    "disabledColor": {
      Store.themeValueLight: Colors.black38,
      Store.themeValueDark: Colors.white54,
    },
    "textColor": {
      Store.themeValueLight: Colors.black54,
      Store.themeValueDark: Colors.white70,
    },
    "textColorOnSecondary": {
      Store.themeValueLight: Colors.black54,
      Store.themeValueDark: Colors.black54,
    },
    "subtextColor": {
      Store.themeValueLight: Colors.black38,
      Store.themeValueDark: Colors.white54,
    },
    "shadowColor": {
      Store.themeValueLight: Colors.black38,
      Store.themeValueDark: Colors.black38,
    },
  };

  Color get primaryColor => _colors["primaryColor"]![_theme]!;

  Color get secondaryColor => _colors["secondaryColor"]![_theme]!;

  Color get colorOnSecondary => _colors["colorOnSecondary"]![_theme]!;

  Color get accentColor => _colors["accentColor"]![_theme]!;

  Color get disabledColor => _colors["disabledColor"]![_theme]!;

  Color get textColor => _colors["textColor"]![_theme]!;

  Color get textColorOnSecondary => _colors["textColorOnSecondary"]![_theme]!;

  Color get subtextColor => _colors["subtextColor"]![_theme]!;

  Color get shadowColor => _colors["shadowColor"]![_theme]!;

  const ResColors(this._theme);
}
