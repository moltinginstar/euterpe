import "package:equatable/equatable.dart";

abstract class VisualizerState extends Equatable {
  final List<double> waveform;

  const VisualizerState({required this.waveform});

  @override
  List<Object> get props => [waveform];
}

class VisualizerInitial extends VisualizerState {
  const VisualizerInitial({required List<double> waveform})
      : super(waveform: waveform);
}

class VisualizerRunPause extends VisualizerState {
  const VisualizerRunPause({required List<double> waveform})
      : super(waveform: waveform);
}

class VisualizerRunInProgress extends VisualizerState {
  const VisualizerRunInProgress({required List<double> waveform})
      : super(waveform: waveform);
}
