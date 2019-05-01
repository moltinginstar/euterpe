import "dart:async";

import "package:euterpe/blocs/blocs.dart";
import "package:euterpe/services/recorder.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";

class TimerBloc extends HydratedBloc<TimerEvent, TimerState> {
  StreamSubscription<dynamic>? _elapsedTimeSubscription;

  TimerBloc() : super(TimerInitial(elapsedTime: 0)) {
    if (state is TimerRunInProgress) {
      _elapsedTimeSubscription ??= Recorder.recorderElapsedTimeStream
          .receiveBroadcastStream([]).listen(
              (i) => add(TimerTicked(elapsedTime: i)));
    } else if (state is TimerRunPause) {
      _elapsedTimeSubscription ??= Recorder.recorderElapsedTimeStream
          .receiveBroadcastStream([]).listen(
              (i) => add(TimerTicked(elapsedTime: i)))
            ..pause();
    }
  }

  @override
  Stream<TimerState> mapEventToState(TimerEvent event) async* {
    if (event is TimerStarted) {
      yield* _mapTimerStartedToState(event);
    } else if (event is TimerPaused) {
      yield* _mapTimerPausedToState(event);
    } else if (event is TimerResumed) {
      yield* _mapTimerResumedToState(event);
    } else if (event is TimerReset) {
      yield* _mapTimerResetToState(event);
    } else if (event is TimerTicked) {
      yield* _mapTimerTickedToState(event);
    }
  }

  @override
  Future<void> close() {
    _elapsedTimeSubscription?.cancel();
    _elapsedTimeSubscription = null;

    return super.close();
  }

  Stream<TimerState> _mapTimerStartedToState(TimerStarted start) async* {
    yield TimerRunInProgress(elapsedTime: 0);

    _elapsedTimeSubscription ??= Recorder.recorderElapsedTimeStream
        .receiveBroadcastStream([]).listen(
            (i) => add(TimerTicked(elapsedTime: i)));
  }

  Stream<TimerState> _mapTimerPausedToState(TimerPaused pause) async* {
    if (state is TimerRunInProgress) {
      _elapsedTimeSubscription?.pause();

      yield TimerRunPause(elapsedTime: state.elapsedTime);
    }
  }

  Stream<TimerState> _mapTimerResumedToState(TimerResumed resume) async* {
    if (state is TimerRunPause) {
      _elapsedTimeSubscription?.resume();

      yield TimerRunInProgress(elapsedTime: state.elapsedTime);
    }
  }

  Stream<TimerState> _mapTimerResetToState(TimerReset reset) async* {
    yield TimerInitial(elapsedTime: 0);

    await _elapsedTimeSubscription?.cancel();
    _elapsedTimeSubscription = null;
  }

  Stream<TimerState> _mapTimerTickedToState(TimerTicked tick) async* {
    yield TimerRunInProgress(elapsedTime: tick.elapsedTime);
  }

  @override
  TimerState? fromJson(Map<String, dynamic> json) {
    final elapsedTime = json["elapsedTime"] ?? 0;
    switch (json["stateName"]) {
      case "TimerRunInProgress":
        return TimerRunInProgress(elapsedTime: elapsedTime);
      case "TimerRunPause":
        return TimerRunPause(elapsedTime: elapsedTime);
      default:
        return TimerInitial(elapsedTime: 0);
    }
  }

  @override
  Map<String, dynamic>? toJson(TimerState state) => {
        "elapsedTime": state.elapsedTime,
        "stateName": _getStateNameFromState(state),
      };

  String _getStateNameFromState(TimerState state) {
    if (state is TimerRunInProgress) {
      return "TimerRunInProgress";
    } else if (state is TimerRunPause) {
      return "TimerRunPause";
    } else {
      return "TimerInitial";
    }
  }
}
