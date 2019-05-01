import "package:easy_localization/easy_localization.dart";
import "package:euterpe/blocs/blocs.dart";
import "package:euterpe/res/res.dart";
import "package:euterpe/services/store.dart";
import "package:euterpe/utils/utils.dart";
import "package:euterpe/views/components/large_icon_button.dart";
import "package:euterpe/views/components/tab_title.dart";
import "package:euterpe/views/components/timer_text.dart";
import "package:euterpe/views/components/visualizer/recorder_visualizer.dart";
import "package:euterpe/views/overlays/recording_title_dialog.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class RecordTab extends StatefulWidget {
  RecordTab({Key? key}) : super(key: key);

  @override
  _RecordTabState createState() => _RecordTabState();
}

class _RecordTabState extends State<RecordTab> {
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => TimerBloc(),
        child: BlocProvider(
          create: (context) => VisualizerBloc(),
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: ResDimens.bottomNavigationBarHeight +
                  ResDimens.bottomNavigationBarMargin,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabTitle(title: ResStrings.recordTitle.tr()),
                Padding(
                  padding: const EdgeInsets.only(
                    left: ResDimens.mainPadding,
                    right: ResDimens.mainPadding,
                    bottom: ResDimens.illustrationCaptionMargin,
                  ),
                  child: TimerText(),
                ),
                Expanded(
                  child: RecorderVisualizer(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: ResDimens.largeIconButtonVerticalMargin,
                  ),
                  child: BlocBuilder<RecorderBloc, RecorderState>(
                    builder: (context, state) => Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state is RecorderRunPause)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: ResDimens.largeIconButtonHorizontalMargin,
                            ),
                            child: Material(
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                highlightColor:
                                    Theme.of(context).highlightColor,
                                child: SizedBox(
                                  width: ResDimens.iconButtonSize,
                                  height: ResDimens.iconButtonSize,
                                  child: Icon(
                                    Icons.close_outlined,
                                    color: Theme.of(context).accentColor,
                                    size: ResDimens.iconButtonIconSize,
                                  ),
                                ),
                                onTap: () {
                                  BlocProvider.of<RecorderBloc>(context)
                                      .add(RecorderCanceled());
                                  BlocProvider.of<TimerBloc>(context)
                                      .add(TimerReset());
                                  BlocProvider.of<VisualizerBloc>(context)
                                      .add(VisualizerReset());
                                },
                              ),
                            ),
                          ),
                        LargeIconButton(
                            color: const ResColors(Store.themeValueLight)
                                .secondaryColor,
                            highlightColor: Theme.of(context).highlightColor,
                            shadowColor: const ResColors(Store.themeValueLight)
                                .shadowColor,
                            icon: state is RecorderRunInProgress
                                ? Icons.pause_outlined
                                : Icons.fiber_manual_record_outlined,
                            iconColor: const ResColors(Store.themeValueLight)
                                .colorOnSecondary,
                            onPressed: () async {
                              if (await getPermissions(context)) {
                                if (state is RecorderInitial) {
                                  BlocProvider.of<RecorderBloc>(context)
                                      .add(RecorderStarted());
                                  BlocProvider.of<TimerBloc>(context)
                                      .add(TimerStarted());
                                  BlocProvider.of<VisualizerBloc>(context)
                                      .add(VisualizerStarted());
                                } else if (state is RecorderRunPause) {
                                  BlocProvider.of<RecorderBloc>(context)
                                      .add(RecorderResumed());
                                  BlocProvider.of<TimerBloc>(context)
                                      .add(TimerResumed());
                                  BlocProvider.of<VisualizerBloc>(context)
                                      .add(VisualizerResumed());
                                } else {
                                  BlocProvider.of<RecorderBloc>(context)
                                      .add(RecorderPaused());
                                  BlocProvider.of<TimerBloc>(context)
                                      .add(TimerPaused());
                                  BlocProvider.of<VisualizerBloc>(context)
                                      .add(VisualizerPaused());
                                }
                              }
                            }),
                        if (state is RecorderRunPause)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: ResDimens.largeIconButtonHorizontalMargin,
                            ),
                            child: Material(
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                highlightColor:
                                    Theme.of(context).highlightColor,
                                child: SizedBox(
                                  width: ResDimens.iconButtonSize,
                                  height: ResDimens.iconButtonSize,
                                  child: Icon(
                                    Icons.check_outlined,
                                    color: Theme.of(context).accentColor,
                                    size: ResDimens.iconButtonIconSize,
                                  ),
                                ),
                                onTap: () async {
                                  if (await getPermissions(context)) {
                                    await getSaveLocation();

                                    final title = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          RecordingTitleDialog(""),
                                    );
                                    if (title != null) {
                                      BlocProvider.of<RecorderBloc>(context)
                                          .add(RecorderStopped(title: title));
                                      BlocProvider.of<TimerBloc>(context)
                                          .add(TimerReset());
                                      BlocProvider.of<VisualizerBloc>(context)
                                          .add(VisualizerReset());
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
