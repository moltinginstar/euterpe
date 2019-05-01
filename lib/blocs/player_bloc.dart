import "package:easy_localization/easy_localization.dart";
import "package:euterpe/blocs/blocs.dart";
import "package:euterpe/res/res.dart";
import "package:euterpe/services/player.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";

class PlayerBloc extends HydratedBloc<PlayerEvent, PlayerState> {
  final Player player;

  PlayerBloc({required this.player}) : super(PlayerInitial()) {
    Player.playerClient.setMethodCallHandler((call) async {
      switch (call.method) {
        case "completed":
          add(PlayerStopped());

          return null;
      }
    });
  }

  @override
  Future<void> close() {
    Player.playerClient.setMethodCallHandler(null);

    return super.close();
  }

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async* {
    try {
      if (event is PlayerStarted) {
        await player.start(
          title: event.title,
          path: event.path,
          notificationTitle: ResStrings.textPlaying.tr(),
        );

        yield PlayerRunInProgress();
      } else if (event is PlayerPaused) {
        await player.pause(notificationTitle: ResStrings.textPaused.tr());

        yield PlayerRunInProgress();
      } else if (event is PlayerResumed) {
        await player.resume(notificationTitle: ResStrings.textPlaying.tr());

        yield PlayerRunInProgress();
      } else if (event is PlayerStopped) {
        await player.stop();

        yield PlayerInitial();
      }
    } catch (_) {
      yield PlayerLoadFailure();
    }
  }

  @override
  PlayerState? fromJson(Map<String, dynamic> json) {
    switch (json["stateName"]) {
      case "PlayerRunInProgress":
        return PlayerRunInProgress();
      default:
        return PlayerInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(PlayerState state) => {
        "stateName": _getStateNameFromState(state),
      };

  String _getStateNameFromState(PlayerState state) {
    if (state is PlayerRunInProgress) {
      return "PlayerRunInProgress";
    } else {
      return "PlayerInitial";
    }
  }
}
