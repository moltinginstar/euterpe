import "package:equatable/equatable.dart";

abstract class RecorderState extends Equatable {
  const RecorderState();

  @override
  List<Object> get props => [];
}

class RecorderInitial extends RecorderState {}

class RecorderRunInProgress extends RecorderState {}

class RecorderRunPause extends RecorderState {}

class RecorderLoadFailure extends RecorderState {}
