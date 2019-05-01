import "package:equatable/equatable.dart";

abstract class RecorderEvent extends Equatable {
  const RecorderEvent();

  @override
  List<Object> get props => [];
}

class RecorderStarted extends RecorderEvent {}

class RecorderPaused extends RecorderEvent {}

class RecorderResumed extends RecorderEvent {}

class RecorderStopped extends RecorderEvent {
  final String title;

  const RecorderStopped({required this.title});

  @override
  List<Object> get props => [title];
}

class RecorderCanceled extends RecorderEvent {}
