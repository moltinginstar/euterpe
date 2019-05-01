import "package:equatable/equatable.dart";

abstract class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object> get props => [];
}

class PlayerInitial extends PlayerState {}

class PlayerRunInProgress extends PlayerState {}

class PlayerLoadFailure extends PlayerState {}
