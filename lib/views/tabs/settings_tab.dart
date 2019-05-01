import "package:easy_localization/easy_localization.dart";
import "package:euterpe/blocs/blocs.dart";
import "package:euterpe/main.dart";
import "package:euterpe/res/res.dart";
import "package:euterpe/services/store.dart";
import "package:euterpe/utils/utils.dart";
import "package:euterpe/views/components/divider.dart";
import "package:euterpe/views/components/setting.dart";
import "package:euterpe/views/components/tab_title.dart";
import "package:euterpe/views/overlays/top_snackbar.dart";
import "package:euterpe/views/routes/bottom_sheet_route.dart";
import "package:flutter/material.dart" hide Divider;
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class SettingsTab extends StatefulWidget {
  SettingsTab({Key? key}) : super(key: key);

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  TopSnackbar? _textCopiedTopSnackbar;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
          bottom: ResDimens.bottomNavigationBarMargin,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  TabTitle(title: ResStrings.settingsTitle.tr()),
                  Setting(
                    title: Store.saveLocationKey.tr(),
                    summary: store.saveLocation,
                    onTap: null,
                  ),
                  Setting(
                    title: Store.formatKey.tr(),
                    summary: store.format.tr(),
                    onTap: () async {
                      var _settingBottomSheet;
                      _settingBottomSheet = BottomSheetRoute(
                        title: Store.formatKey.tr(),
                        items: Store.supportedFormats,
                        onTap: (value) async {
                          setState(() => store.format = value);

                          await dismissBottomSheet(_settingBottomSheet);
                        },
                        onStatusChanged: (status) =>
                            BottomNavigationBarVisibilityNotification(
                          isVisible: !_settingBottomSheet.hasElevation,
                        ).dispatch(context),
                      );
                      await Navigator.of(context).push(_settingBottomSheet);
                    },
                  ),
                  Setting(
                    title: Store.qualityKey.tr(),
                    summary: store.quality.tr(),
                    onTap: () async {
                      var _settingBottomSheet;
                      _settingBottomSheet = BottomSheetRoute(
                        title: Store.qualityKey.tr(),
                        items: Store.supportedQualities,
                        onTap: (value) async {
                          setState(() => store.quality = value);

                          await dismissBottomSheet(_settingBottomSheet);
                        },
                        onStatusChanged: (status) =>
                            BottomNavigationBarVisibilityNotification(
                          isVisible: !_settingBottomSheet.hasElevation,
                        ).dispatch(context),
                      );
                      await Navigator.of(context).push(_settingBottomSheet);
                    },
                  ),
                  Setting(
                    title: Store.channelsKey.tr(),
                    summary: store.channels.tr(),
                    onTap: () async {
                      var _settingBottomSheet;
                      _settingBottomSheet = BottomSheetRoute(
                        title: Store.channelsKey.tr(),
                        items: Store.supportedChannels,
                        onTap: (value) async {
                          setState(() => store.channels = value);

                          await dismissBottomSheet(_settingBottomSheet);
                        },
                        onStatusChanged: (status) =>
                            BottomNavigationBarVisibilityNotification(
                          isVisible: !_settingBottomSheet.hasElevation,
                        ).dispatch(context),
                      );
                      await Navigator.of(context).push(_settingBottomSheet);
                    },
                  ),
                  Setting(
                    title: Store.echoCancellationKey.tr(),
                    summary: store.echoCancellation.tr(),
                    onTap: () async {
                      var _settingBottomSheet;
                      _settingBottomSheet = BottomSheetRoute(
                        title: Store.echoCancellationKey.tr(),
                        items: Store.supportedEchoCancellationModes,
                        onTap: (value) async {
                          setState(() => store.echoCancellation = value);

                          await dismissBottomSheet(_settingBottomSheet);
                        },
                        onStatusChanged: (status) =>
                            BottomNavigationBarVisibilityNotification(
                          isVisible: !_settingBottomSheet.hasElevation,
                        ).dispatch(context),
                      );
                      await Navigator.of(context).push(_settingBottomSheet);
                    },
                  ),
                  Setting(
                    title: Store.noiseSuppressionKey.tr(),
                    summary: store.noiseSuppression.tr(),
                    onTap: () async {
                      var _settingBottomSheet;
                      _settingBottomSheet = BottomSheetRoute(
                        title: Store.noiseSuppressionKey.tr(),
                        items: Store.supportedNoiseSuppressionModes,
                        onTap: (value) async {
                          setState(() => store.noiseSuppression = value);

                          await dismissBottomSheet(_settingBottomSheet);
                        },
                        onStatusChanged: (status) =>
                            BottomNavigationBarVisibilityNotification(
                          isVisible: !_settingBottomSheet.hasElevation,
                        ).dispatch(context),
                      );
                      await Navigator.of(context).push(_settingBottomSheet);
                    },
                  ),
                  Divider(),
                  Setting(
                    title: Store.themeKey.tr(),
                    summary: store.theme.tr(),
                    onTap: () async {
                      var _settingBottomSheet;
                      _settingBottomSheet = BottomSheetRoute(
                        title: Store.themeKey.tr(),
                        items: Store.supportedThemes,
                        onTap: (value) async {
                          setState(() => store.theme = value);
                          BlocProvider.of<ThemeBloc>(context).add(
                            ThemeChanged(theme: value),
                          );

                          await dismissBottomSheet(_settingBottomSheet);
                        },
                        onStatusChanged: (status) =>
                            BottomNavigationBarVisibilityNotification(
                          isVisible: !_settingBottomSheet.hasElevation,
                        ).dispatch(context),
                      );
                      await Navigator.of(context).push(_settingBottomSheet);
                    },
                  ),
                  Setting(
                    title: Store.languageKey.tr(),
                    summary: store.language.tr(),
                    onTap: () async {
                      var _settingBottomSheet;
                      _settingBottomSheet = BottomSheetRoute(
                        title: Store.languageKey.tr(),
                        items: Store.supportedLanguages,
                        onTap: (value) async {
                          setState(() => store.language = value);
                          context.setLocale(getLocale());

                          await dismissBottomSheet(_settingBottomSheet);
                        },
                        onStatusChanged: (status) =>
                            BottomNavigationBarVisibilityNotification(
                          isVisible: !_settingBottomSheet.hasElevation,
                        ).dispatch(context),
                      );
                      await Navigator.of(context).push(_settingBottomSheet);
                    },
                  ),
                  Setting(
                    title: Store.keepScreenOnKey.tr(),
                    summary: store.keepScreenOn.tr(),
                    onTap: () async {
                      var _settingBottomSheet;
                      _settingBottomSheet = BottomSheetRoute(
                        title: Store.keepScreenOnKey.tr(),
                        items: Store.keepScreenOnModes,
                        onTap: (value) async {
                          setState(() => store.keepScreenOn = value);
                          setKeepScreenOn(value == Store.keepScreenOnValueOn);

                          await dismissBottomSheet(_settingBottomSheet);
                        },
                        onStatusChanged: (status) =>
                            BottomNavigationBarVisibilityNotification(
                          isVisible: !_settingBottomSheet.hasElevation,
                        ).dispatch(context),
                      );
                      await Navigator.of(context).push(_settingBottomSheet);
                    },
                  ),
                  Divider(),
                  Setting(
                    title: ResStrings.aboutTitle.tr(),
                    summary: ResStrings.versionPlaceholder.tr() + store.version,
                    onTap: () async {
                      var _settingBottomSheet;
                      _settingBottomSheet = BottomSheetRoute(
                        title: ResStrings.aboutTitle.tr(),
                        items: [
                          "${ResStrings.appName.tr()} ${ResStrings.textRecorder.tr()}",
                          store.packageName,
                          ResStrings.versionPlaceholder.tr() + store.version,
                        ],
                        itemsAreKeys: false,
                        onTap: (value) async {
                          Clipboard.setData(ClipboardData(text: value));

                          _textCopiedTopSnackbar?.dismiss();
                          _textCopiedTopSnackbar = TopSnackbar(
                            message: Text(
                              ResStrings.textTextCopied.tr(),
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    color:
                                        const ResColors(Store.themeValueLight)
                                            .textColor,
                                  ),
                            ),
                            backgroundColor:
                                const ResColors(Store.themeValueLight)
                                    .secondaryColor,
                            borderRadius: ResDimens.radius,
                            duration: const Duration(seconds: 2),
                            forwardAnimationCurve: Curves.bounceIn,
                            reverseAnimationCurve: Curves.bounceIn,
                            onStatusChanged: (status) =>
                                TopSnackbarVisibilityNotification(
                              isVisible: status == TopSnackbarStatus.completed,
                            ).dispatch(context),
                          )..show(context);
                        },
                        onStatusChanged: (status) =>
                            BottomNavigationBarVisibilityNotification(
                          isVisible: !_settingBottomSheet.hasElevation,
                        ).dispatch(context),
                      );
                      await Navigator.of(context).push(_settingBottomSheet);
                    },
                  ),
                  SizedBox(height: ResDimens.bottomNavigationBarHeight),
                ],
              ),
            ),
          ],
        ),
      );
}
