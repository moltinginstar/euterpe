import "dart:async";
import "dart:io";

import "package:easy_localization/easy_localization.dart";
import "package:euterpe/blocs/blocs.dart";
import "package:euterpe/main.dart";
import "package:euterpe/models/models.dart";
import "package:euterpe/res/res.dart";
import "package:euterpe/services/store.dart";
import "package:euterpe/utils/utils.dart";
import "package:euterpe/views/components/large_icon_button.dart";
import "package:euterpe/views/components/lyre_illustration.dart";
import "package:euterpe/views/components/recording_card.dart";
import "package:euterpe/views/components/tab_title.dart";
import "package:euterpe/views/overlays/recording_title_dialog.dart";
import "package:euterpe/views/routes/bottom_sheet_route.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:sorted_list/sorted_list.dart";
import "package:watcher/watcher.dart";

const playerMethods = MethodChannel("com.sd.euterpe/player");
const playerStream = EventChannel("com.sd.euterpe/player_stream");

class RecordingsTab extends StatefulWidget {
  RecordingsTab({Key? key}) : super(key: key);

  @override
  _RecordingsTabState createState() => _RecordingsTabState();
}

class _RecordingsTabState extends State<RecordingsTab>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;

  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _elevationAnimation;

  Directory? _recordingsDirectory;
  StreamSubscription<WatchEvent>? _recordingsWatcherSubscription;

  final _recordings = SortedList<Recording>((a, b) => b.date.compareTo(a.date));
  var _currentRecording = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: store.longPressDuration ~/ 2),
      vsync: this,
    );
    _scaleAnimation = Tween(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.decelerate,
    ));
    _elevationAnimation = Tween(
      begin: ResDimens.recordingCardElevation,
      end: ResDimens.recordingCardPressedElevation,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.decelerate,
    ));

    _loadRecordings();
  }

  @override
  void dispose() {
    _animationController.dispose();

    _recordingsWatcherSubscription?.cancel();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final width = MediaQuery.of(context).size.width;
    _pageController = PageController(
      viewportFraction: (width - 2 * ResDimens.mainPadding) / width,
    );

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _loadRecordings();

    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.only(
          bottom: ResDimens.bottomNavigationBarHeight +
              ResDimens.bottomNavigationBarMargin,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabTitle(title: ResStrings.recordingsTitle.tr()),
            Expanded(
              child: _recordings.isNotEmpty
                  ? PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (i) async {
                        BlocProvider.of<PlayerBloc>(context)
                            .add(PlayerStopped());

                        setState(() => _currentRecording = i);
                      },
                      itemBuilder: (context, i) => IgnorePointer(
                        ignoring: i != _currentRecording,
                        child: GestureDetector(
                          onTapDown: (details) =>
                              _animationController.forward(),
                          onTapUp: (details) => _animationController.reverse(),
                          onTapCancel: () => _animationController.reverse(),
                          onLongPress: () async {
                            var _recordingBottomSheet;
                            _recordingBottomSheet = BottomSheetRoute(
                              title: _recordings[i].title,
                              items: [
                                ResStrings.textRename,
                                ResStrings.textDelete,
                              ],
                              onTaps: [
                                () async {
                                  if (await getPermissions(context)) {
                                    await getSaveLocation();

                                    final String? newTitle = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          RecordingTitleDialog(
                                              _recordings[i].title),
                                    );
                                    if (newTitle != null &&
                                        newTitle != _recordings[i].title &&
                                        newTitle.isNotEmpty) {
                                      final newPath = await getRecordingNewPath(
                                        newTitle: newTitle,
                                        path: _recordings[i].path,
                                      );
                                      if (newPath != null) {
                                        await File(_recordings[i].path)
                                            .rename(newPath);
                                      }
                                    }

                                    await dismissBottomSheet(
                                        _recordingBottomSheet);
                                  }
                                },
                                () async {
                                  if (await getPermissions(context)) {
                                    await getSaveLocation();

                                    BlocProvider.of<PlayerBloc>(context)
                                        .add(PlayerStopped());

                                    await dismissBottomSheet(
                                        _recordingBottomSheet);

                                    await File(_recordings[i].path).delete();
                                  }
                                },
                              ],
                              onStatusChanged: (status) =>
                                  BottomNavigationBarVisibilityNotification(
                                          isVisible: !_recordingBottomSheet
                                              .hasElevation)
                                      .dispatch(context),
                            );
                            await Navigator.of(context)
                                .push(_recordingBottomSheet);
                          },
                          child: i == _currentRecording
                              ? ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) => RecordingCard(
                                      recording: _recordings[i],
                                      elevationAnimation: _elevationAnimation,
                                    ),
                                  ),
                                )
                              : RecordingCard(
                                  recording: _recordings[i],
                                  elevationAnimation: null,
                                ),
                        ),
                      ),
                      itemCount: _recordings.length,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        LyreIllustration(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ResDimens.mainPadding,
                            vertical: ResDimens.illustrationCaptionMargin,
                          ),
                          child: Text(
                            ResStrings.textNoRecordings.tr(),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        )
                      ],
                    ),
            ),
            if (_recordings.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: ResDimens.largeIconButtonVerticalMargin,
                ),
                child: LargeIconButton(
                  color: const ResColors(Store.themeValueLight).secondaryColor,
                  highlightColor: Theme.of(context).highlightColor,
                  shadowColor:
                      const ResColors(Store.themeValueLight).shadowColor,
                  icon: state is PlayerRunInProgress
                      ? Icons.stop_outlined
                      : Icons.play_arrow_outlined,
                  iconColor:
                      const ResColors(Store.themeValueLight).colorOnSecondary,
                  onPressed: () async {
                    if (state is! PlayerRunInProgress) {
                      BlocProvider.of<PlayerBloc>(context).add(PlayerStarted(
                        title: _recordings[_currentRecording].title,
                        path: _recordings[_currentRecording].path,
                      ));
                    } else {
                      BlocProvider.of<PlayerBloc>(context).add(PlayerStopped());
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _loadRecordings() async {
    if (await checkPermissions()) {
      if (_recordingsDirectory == null &&
          _recordingsWatcherSubscription == null) {
        _recordingsDirectory ??= Directory(store.saveLocation);
        if (mounted && await _recordingsDirectory?.exists() == true) {
          _recordings.addAll(await _recordingsDirectory
                  ?.list()
                  .where((e) => e is File && isRecording(file: e))
                  .map((r) => getRecording(file: r as File))
                  .toList() ??
              []);
          setState(() {});
        }
        _recordingsWatcherSubscription ??=
            DirectoryWatcher(store.saveLocation).events.listen((event) {
          if (event.type == ChangeType.ADD) {
            final file = File(event.path);
            if (mounted && isRecording(file: file)) {
              final recording = getRecording(file: file);
              setState(() => _recordings.add(recording));
            }
          } else if (mounted && event.type == ChangeType.REMOVE) {
            setState(() {
              _recordings.removeWhere((e) => e.path == event.path);
            });
          }
        });
      }
    } else {
      _recordingsDirectory = null;
      _recordingsWatcherSubscription?.cancel();
      _recordingsWatcherSubscription = null;

      setState(() => _recordings.clear());
    }
  }
}
