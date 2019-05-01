import "package:easy_localization/easy_localization.dart";
import "package:euterpe/blocs/blocs.dart";
import "package:euterpe/res/res.dart";
import "package:euterpe/services/store.dart";
import "package:euterpe/utils/utils.dart";
import "package:euterpe/views/app.dart";
import "package:flare_flutter/flare_cache.dart";
import "package:flare_flutter/provider/asset_flare.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";
import "package:path_provider/path_provider.dart";

late final Store store;
late final ThemeData lightTheme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  store = await Store.getInstance();
  lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const ResColors(Store.themeValueLight).primaryColor,
    accentColor: const ResColors(Store.themeValueLight).accentColor,
    disabledColor: const ResColors(Store.themeValueLight).disabledColor,
    highlightColor: Colors.transparent,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: const ResColors(Store.themeValueLight).accentColor,
      selectionColor:
          const ResColors(Store.themeValueLight).accentColor.withOpacity(0.5),
      selectionHandleColor: const ResColors(Store.themeValueLight).accentColor,
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
        color: const ResColors(Store.themeValueLight).accentColor,
        fontSize: ResDimens.largeTitleFontSize,
        fontWeight: FontWeight.w700,
      ),
      subtitle2: TextStyle(
        color: const ResColors(Store.themeValueLight).colorOnSecondary,
        fontSize: ResDimens.smallTitleFontSize,
        fontWeight: FontWeight.w700,
      ),
      headline4: TextStyle(
        color: Colors.white,
        fontSize: ResDimens.subtitleFontSize,
        fontWeight: FontWeight.w400,
      ),
      headline3: TextStyle(
        color: Colors.white,
        fontSize: ResDimens.mediumTitleFontSize,
        fontWeight: FontWeight.w700,
      ),
      bodyText2: TextStyle(
        color: const ResColors(Store.themeValueLight).subtextColor,
        fontSize: ResDimens.subtextFontSize,
        fontWeight: FontWeight.w400,
      ),
      bodyText1: TextStyle(
        color: const ResColors(Store.themeValueLight).textColor,
        fontSize: ResDimens.textFontSize,
        fontWeight: FontWeight.w500,
      ),
    ),
    fontFamily: "MontserratAlternates",
  );

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: (await getExternalStorageDirectory())!,
  );
  [
    "assets/animations/divider_dark.flr",
    "assets/animations/divider_light.flr",
    "assets/animations/lyre_dark.flr",
    "assets/animations/lyre_light.flr",
  ].forEach((element) async =>
      await cachedActor(AssetFlare(bundle: rootBundle, name: element)));

  SystemChrome.setSystemUIOverlayStyle(getSystemUiOverlayStyle(
    WidgetsBinding.instance!.platformDispatcher.platformBrightness,
    true,
    false,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  setKeepScreenOn(store.keepScreenOn == Store.keepScreenOnValueOn);

  runApp(EasyLocalization(
    path: "assets/strings",
    supportedLocales: Store.supportedLocales,
    fallbackLocale: const Locale(Store.languageValueEnglish),
    startLocale: getLocale(),
    saveLocale: false,
    useFallbackTranslations: true,
    useOnlyLangCode: true,
    child: BlocProvider(
      create: (context) => ThemeBloc(savedTheme: store.theme),
      child: EuterpeApp(),
    ),
  ));
}
