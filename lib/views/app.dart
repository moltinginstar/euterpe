import "package:easy_localization/easy_localization.dart";
import "package:euterpe/blocs/blocs.dart";
import "package:euterpe/main.dart";
import "package:euterpe/res/res.dart";
import "package:euterpe/services/store.dart";
import "package:euterpe/utils/utils.dart";
import "package:euterpe/views/home_page.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class EuterpeApp extends StatefulWidget {
  EuterpeApp({Key? key}) : super(key: key);

  @override
  _EuterpeAppState createState() => _EuterpeAppState();
}

class _EuterpeAppState extends State<EuterpeApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    context.setLocale(getLocale());

    super.didChangeLocales(locales);
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) => MaterialApp(
            onGenerateTitle: (context) =>
                "${ResStrings.appName.tr()} ${ResStrings.textRecorder.tr()}",
            theme: lightTheme,
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: const ResColors(Store.themeValueDark).primaryColor,
              accentColor: const ResColors(Store.themeValueDark).accentColor,
              disabledColor:
                  const ResColors(Store.themeValueDark).disabledColor,
              highlightColor: Colors.transparent,
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: const ResColors(Store.themeValueDark).accentColor,
                selectionColor: const ResColors(Store.themeValueDark)
                    .accentColor
                    .withOpacity(0.5),
                selectionHandleColor:
                    const ResColors(Store.themeValueDark).accentColor,
              ),
              textTheme: TextTheme(
                headline1: TextStyle(
                  color: const ResColors(Store.themeValueDark).accentColor,
                  fontSize: ResDimens.largeTitleFontSize,
                  fontWeight: FontWeight.w700,
                ),
                subtitle2: TextStyle(
                  color: const ResColors(Store.themeValueDark).colorOnSecondary,
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
                  color: const ResColors(Store.themeValueDark).subtextColor,
                  fontSize: ResDimens.subtextFontSize,
                  fontWeight: FontWeight.w400,
                ),
                bodyText1: TextStyle(
                  color: const ResColors(Store.themeValueDark).textColor,
                  fontSize: ResDimens.textFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              fontFamily: "MontserratAlternates",
            ),
            themeMode: themeState.themeMode,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            home: EuterpeHomePage(),
            builder: (context, child) => MediaQuery(
              child: child!,
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            ),
          ));
}
