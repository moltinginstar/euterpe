import "dart:io";

import "package:easy_localization/easy_localization.dart";
import "package:euterpe/main.dart";
import "package:euterpe/services/store.dart";
import "package:flutter/material.dart";

Locale getLocale() {
  var newLocale;
  if (store.language == Store.languageValueAuto) {
    var systemLocale = Locale(Platform.localeName.toLocale().languageCode);
    if (Store.supportedLocales.contains(systemLocale)) {
      newLocale = systemLocale;
    } else {
      newLocale =
          const Locale(Store.languageValueEnglish); // context.fallbackLocale
    }
  } else {
    newLocale = Locale(store.language);
  }

  return newLocale;
}
