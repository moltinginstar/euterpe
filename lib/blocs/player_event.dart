import "package:equatable/equatable.dart";

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object> get props => [];
}

class PlayerStarted extends PlayerEvent {
  final String title;
  final String path;

  const PlayerStarted({required this.title, required this.path});

  @override
  List<Object> get props => [title, path];
}

class PlayerPaused extends PlayerEvent {
  final String title;

  const PlayerPaused({required this.title});

  @override
  List<Object> get props => [title];
}

class PlayerResumed extends PlayerEvent {
  final String title;

  const PlayerResumed({required this.title});

  @override
  List<Object> get props => [title];
}

class PlayerStopped extends PlayerEvent {}
