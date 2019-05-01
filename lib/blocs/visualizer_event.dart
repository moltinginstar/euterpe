import "package:equatable/equatable.dart";

abstract class VisualizerEvent extends Equatable {
  const VisualizerEvent();

  @override
  List<Object> get props => [];
}

class VisualizerStarted extends VisualizerEvent {
  const VisualizerStarted();
}

class VisualizerPaused extends VisualizerEvent {
  const VisualizerPaused();
}

class VisualizerResumed extends VisualizerEvent {
  const VisualizerResumed();
}

class VisualizerReset extends VisualizerEvent {
  const VisualizerReset();
}

class VisualizerUpdated extends VisualizerEvent {
  final List<double> waveform;

  const VisualizerUpdated({required this.waveform});

  @override
  List<Object> get props => [waveform];
}
