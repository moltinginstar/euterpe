import "dart:async";

import "package:euterpe/blocs/blocs.dart";
import "package:euterpe/services/recorder.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";

class VisualizerBloc extends HydratedBloc<VisualizerEvent, VisualizerState> {
  StreamSubscription<dynamic>? _waveformSubscription;

  VisualizerBloc() : super(VisualizerInitial(waveform: [])) {
    if (state is VisualizerRunInProgress) {
      _waveformSubscription ??= Recorder.recorderWaveformStream
          .receiveBroadcastStream([]).listen((w) => add(
              VisualizerUpdated(waveform: List.castFrom<dynamic, double>(w))));
    } else if (state is VisualizerRunPause) {
      _waveformSubscription ??= Recorder.recorderWaveformStream
          .receiveBroadcastStream([]).listen((w) => add(
              VisualizerUpdated(waveform: List.castFrom<dynamic, double>(w))))
            ..pause();
    }
  }

  @override
  Stream<VisualizerState> mapEventToState(VisualizerEvent event) async* {
    if (event is VisualizerStarted) {
      yield* _mapVisualizerStartedToState(event);
    } else if (event is VisualizerPaused) {
      yield* _mapVisualizerPausedToState(event);
    } else if (event is VisualizerResumed) {
      yield* _mapVisualizerResumedToState(event);
    } else if (event is VisualizerReset) {
      yield* _mapVisualizerResetToState(event);
    } else if (event is VisualizerUpdated) {
      yield* _mapVisualizerUpdatedToState(event);
    }
  }

  @override
  Future<void> close() {
    _waveformSubscription?.cancel();
    _waveformSubscription = null;

    return super.close();
  }

  Stream<VisualizerState> _mapVisualizerStartedToState(
      VisualizerStarted start) async* {
    yield VisualizerRunInProgress(waveform: []);

    _waveformSubscription ??= Recorder.recorderWaveformStream
        .receiveBroadcastStream([]).listen((w) => add(
            VisualizerUpdated(waveform: List.castFrom<dynamic, double>(w))));
  }

  Stream<VisualizerState> _mapVisualizerPausedToState(
      VisualizerPaused pause) async* {
    if (state is VisualizerRunInProgress) {
      _waveformSubscription?.pause();

      yield VisualizerRunPause(waveform: state.waveform);
    }
  }

  Stream<VisualizerState> _mapVisualizerResumedToState(
      VisualizerResumed resume) async* {
    if (state is VisualizerRunPause) {
      _waveformSubscription?.resume();

      yield VisualizerRunInProgress(waveform: state.waveform);
    }
  }

  Stream<VisualizerState> _mapVisualizerResetToState(
      VisualizerReset reset) async* {
    yield VisualizerInitial(waveform: []);

    await _waveformSubscription?.cancel();
    _waveformSubscription = null;
  }

  Stream<VisualizerState> _mapVisualizerUpdatedToState(
      VisualizerUpdated update) async* {
    yield VisualizerRunInProgress(waveform: update.waveform);
  }

  @override
  VisualizerState? fromJson(Map<String, dynamic> json) {
    final amplitudes = json["amplitudes"] ?? [];
    switch (json["stateName"]) {
      case "VisualizerRunInProgress":
        return VisualizerRunInProgress(waveform: amplitudes);
      case "VisualizerRunPause":
        return VisualizerRunPause(waveform: amplitudes);
      default:
        return VisualizerInitial(waveform: []);
    }
  }

  @override
  Map<String, dynamic>? toJson(VisualizerState state) => {
        "amplitudes": state.waveform,
        "stateName": _getStateNameFromState(state),
      };

  String _getStateNameFromState(VisualizerState state) {
    if (state is VisualizerRunInProgress) {
      return "VisualizerRunInProgress";
    } else if (state is VisualizerRunPause) {
      return "VisualizerRunPause";
    } else {
      return "VisualizerInitial";
    }
  }
}
