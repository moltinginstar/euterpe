import "package:equatable/equatable.dart";

abstract class TimerState extends Equatable {
  final int elapsedTime;

  const TimerState({required this.elapsedTime});

  @override
  List<Object> get props => [elapsedTime];
}

class TimerInitial extends TimerState {
  const TimerInitial({required int elapsedTime})
      : super(elapsedTime: elapsedTime);
}

class TimerRunPause extends TimerState {
  const TimerRunPause({required int elapsedTime})
      : super(elapsedTime: elapsedTime);
}

class TimerRunInProgress extends TimerState {
  const TimerRunInProgress({required int elapsedTime})
      : super(elapsedTime: elapsedTime);
}
