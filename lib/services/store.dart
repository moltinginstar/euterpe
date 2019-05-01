import "dart:ui";

import "package:euterpe/utils/utils.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:shared_preferences/shared_preferences.dart";

class Store {
  static Store? store;
  static SharedPreferences? _sharedPreferences;
  static PackageInfo? _packageInfo;

  static const saveLocationKey = "saveLocation";

  static const formatKey = "format";
  static const formatValueAac = "aac";
  static const formatValueFlac = "flac";
  static const formatValueM4a = "m4a";
  static const formatValueMp3 = "mp3";
  static const formatValueOgg = "ogg";
  static const formatValueOpus = "opus";
  static const formatValueWav = "wav";
  static const formatValueWma = "wma";

  static const qualityKey = "quality";
  static const qualityValueLow = "qualityLow";
  static const qualityValueMedium = "qualityMedium";
  static const qualityValueHigh = "qualityHigh";
  static const qualityValueBest = "qualityBest";

  static const channelsKey = "channels";
  static const channelsValueMono = "channelsMono";
  static const channelsValueStereo = "channelsStereo";

  static const echoCancellationKey = "echoCancellation";
  static const echoCancellationValueOff = "echoCancellationOff";
  static const echoCancellationValueOn = "echoCancellationOn";

  static const noiseSuppressionKey = "noiseSuppression";
  static const noiseSuppressionValueOff = "noiseSuppressionOff";
  static const noiseSuppressionValueOn = "noiseSuppressionOn";

  static const themeKey = "theme";
  static const themeValueAuto = "themeAuto";
  static const themeValueLight = "light";
  static const themeValueDark = "dark";

  static const languageKey = "language";
  static const languageValueAuto = "languageAuto";
  static const languageValueEnglish = "en";
  static const languageValueSpanish = "es";
  static const languageValueRussian = "ru";

  static const keepScreenOnKey = "keepScreenOn";
  static const keepScreenOnValueOff = "keepScreenOnOff";
  static const keepScreenOnValueOn = "keepScreenOnOn";

  static const supportedFormats = [
    Store.formatValueAac,
    Store.formatValueFlac,
    Store.formatValueM4a,
    Store.formatValueMp3,
    Store.formatValueOgg,
    Store.formatValueOpus,
    Store.formatValueWav,
    Store.formatValueWma,
  ];

  static const supportedQualities = [
    Store.qualityValueLow,
    Store.qualityValueMedium,
    Store.qualityValueHigh,
    Store.qualityValueBest,
  ];

  static const supportedChannels = [
    Store.channelsValueMono,
    Store.channelsValueStereo,
  ];

  static const supportedEchoCancellationModes = [
    Store.echoCancellationValueOff,
    Store.echoCancellationValueOn,
  ];

  static const supportedNoiseSuppressionModes = [
    Store.noiseSuppressionValueOff,
    Store.noiseSuppressionValueOn,
  ];

  static const supportedThemes = [
    Store.themeValueAuto,
    Store.themeValueLight,
    Store.themeValueDark,
  ];

  static const supportedLanguages = [
    Store.languageValueAuto,
    Store.languageValueEnglish,
    Store.languageValueSpanish,
    Store.languageValueRussian,
  ];

  static const keepScreenOnModes = [
    Store.keepScreenOnValueOff,
    Store.keepScreenOnValueOn,
  ];

  static const supportedLocales = [
    const Locale(Store.languageValueEnglish),
    const Locale(Store.languageValueSpanish),
    const Locale(Store.languageValueRussian),
  ];

  static late String _saveLocation;

  String get saveLocation => _saveLocation;

  static late String _format;

  String get format => _format;

  set format(String value) {
    _format = value;
    _sharedPreferences!.setString(formatKey, _format);
  }

  static late String _quality;

  String get quality => _quality;

  set quality(String value) {
    _quality = value;
    _sharedPreferences!.setString(qualityKey, _quality);
  }

  static late String _channels;

  String get channels => _channels;

  set channels(String value) {
    _channels = value;
    _sharedPreferences!.setString(channelsKey, _channels);
  }

  static late String _echoCancellation;

  String get echoCancellation => _echoCancellation;

  set echoCancellation(String value) {
    _echoCancellation = value;
    _sharedPreferences!.setString(echoCancellationKey, _echoCancellation);
  }

  static late String _noiseSuppression;

  String get noiseSuppression => _noiseSuppression;

  set noiseSuppression(String value) {
    _noiseSuppression = value;
    _sharedPreferences!.setString(noiseSuppressionKey, _noiseSuppression);
  }

  static late String _theme;

  String get theme => _theme;

  set theme(String value) {
    _theme = value;
    _sharedPreferences!.setString(themeKey, _theme);
  }

  static late String _language;

  String get language => _language;

  set language(String value) {
    _language = value;
    _sharedPreferences!.setString(languageKey, _language);
  }

  static late String _keepScreenOn;

  String get keepScreenOn => _keepScreenOn;

  set keepScreenOn(String value) {
    _keepScreenOn = value;
    _sharedPreferences!.setString(keepScreenOnKey, _keepScreenOn);
  }

  String get version => _packageInfo!.version;

  String get packageName => _packageInfo!.packageName;

  static late int _longPressDuration;

  int get longPressDuration => _longPressDuration;

  Store._();

  static Future<Store> getInstance() async {
    store ??= Store._();
    _sharedPreferences ??= await SharedPreferences.getInstance();
    _packageInfo ??= await PackageInfo.fromPlatform();

    _saveLocation = _sharedPreferences!.getString(saveLocationKey) ??
        await getSaveLocation();
    store!.format = _sharedPreferences!.getString(formatKey) ?? formatValueM4a;
    store!.quality =
        _sharedPreferences!.getString(qualityKey) ?? qualityValueHigh;
    store!.channels =
        _sharedPreferences!.getString(channelsKey) ?? channelsValueMono;
    store!.echoCancellation =
        _sharedPreferences!.getString(echoCancellationKey) ??
            echoCancellationValueOff;
    store!.noiseSuppression =
        _sharedPreferences!.getString(noiseSuppressionKey) ??
            noiseSuppressionValueOff;
    store!.theme = _sharedPreferences!.getString(themeKey) ?? themeValueAuto;
    store!.language =
        _sharedPreferences!.getString(languageKey) ?? languageValueAuto;
    store!.keepScreenOn =
        _sharedPreferences!.getString(keepScreenOnKey) ?? keepScreenOnValueOn;
    _longPressDuration = await getLongPressDuration();

    return store!;
  }
}
