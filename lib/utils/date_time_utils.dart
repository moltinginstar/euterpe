import "package:easy_localization/easy_localization.dart";
import "package:euterpe/services/store.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

String formatDate(BuildContext context, DateTime date) {
  final localDate = date.toLocal();

  final currentYear = DateTime.now().year;
  final localeCode = context.locale.languageCode;

  final dateFormat = localDate.year == currentYear
      ? DateFormat.MMMEd(localeCode)
      : DateFormat.yMMMEd(localeCode);
  final timeFormat = localeCode == Store.languageValueEnglish
      ? DateFormat.jm(localeCode)
      : DateFormat.Hm(localeCode);

  return "${dateFormat.format(localDate)} • ${timeFormat.format(localDate)}";
}

List<String> formatTime({required int timeInMillis}) {
  final millis = timeInMillis % 1000;
  final seconds = (timeInMillis - millis) ~/ 1000 % 60;
  final minutes = ((timeInMillis - millis) ~/ 1000 - seconds) ~/ 60;

  final mm = minutes.toString().padLeft(2, "0");
  final ss = seconds.toString().padLeft(2, "0");
  final nn = (millis ~/ 10).toString().padLeft(2, "0");

  return ["$mm:$ss", ".$nn"];
}
