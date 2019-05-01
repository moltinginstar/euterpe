import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:euterpe/blocs/blocs.dart";
import "package:euterpe/main.dart";
import "package:euterpe/res/res.dart";
import "package:euterpe/services/recorder.dart";
import "package:euterpe/services/store.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";

class RecorderBloc extends HydratedBloc<RecorderEvent, RecorderState> {
  final Recorder recorder;

  RecorderBloc({required this.recorder}) : super(RecorderInitial());

  @override
  Stream<RecorderState> mapEventToState(RecorderEvent event) async* {
    try {
      if (event is RecorderStarted) {
        final format = store.format;
        final quality = store.quality;
        final channels = store.channels;
        final echoCancellation =
            store.echoCancellation == Store.echoCancellationValueOn;
        final noiseSuppression =
            store.noiseSuppression == Store.noiseSuppressionValueOn;

        await recorder.start(
          format: format,
          quality: quality,
          channels: channels,
          echoCancellation: echoCancellation,
          noiseSuppression: noiseSuppression,
          notificationTitle: ResStrings.textRecording.tr(),
        );

        yield RecorderRunInProgress();
      } else if (event is RecorderPaused) {
        await recorder.pause(notificationTitle: ResStrings.textPaused.tr());

        yield RecorderRunPause();
      } else if (event is RecorderResumed) {
        await recorder.resume(notificationTitle: ResStrings.textRecording.tr());

        yield RecorderRunInProgress();
      } else if (event is RecorderStopped) {
        await recorder.stop(title: event.title);

        yield RecorderInitial();
      } else if (event is RecorderCanceled) {
        await recorder.cancel();

        yield RecorderInitial();
      }
    } catch (_) {
      yield RecorderLoadFailure();
    }
  }

  @override
  RecorderState? fromJson(Map<String, dynamic> json) {
    switch (json["stateName"]) {
      case "RecorderRunInProgress":
        return RecorderRunInProgress();
      case "RecorderRunPause":
        return RecorderRunPause();
      default:
        return RecorderInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(RecorderState state) => {
        "stateName": _getStateNameFromState(state),
      };

  String _getStateNameFromState(RecorderState state) {
    if (state is RecorderRunInProgress) {
      return "RecorderRunInProgress";
    } else if (state is RecorderRunPause) {
      return "RecorderRunPause";
    } else {
      return "RecorderInitial";
    }
  }
}
