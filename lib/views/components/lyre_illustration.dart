import "package:euterpe/res/res.dart";
import "package:euterpe/utils/utils.dart";
import "package:flare_flutter/flare_actor.dart";
import "package:flare_flutter/flare_controls.dart";
import "package:flutter/material.dart";
import "package:just_audio/just_audio.dart";

class LyreIllustration extends StatefulWidget {
  const LyreIllustration({Key? key}) : super(key: key);

  @override
  _LyreIllustrationState createState() => _LyreIllustrationState();
}

class _LyreIllustrationState extends State<LyreIllustration> {
  final _illustrationController = FlareControls();
  var _stringsTouched = false;

  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: SizedBox(
          height: ResDimens.illustrationHeight,
          child: FlareActor(
            "assets/animations/lyre_${getThemeString(context)}.flr",
            animation: "start",
            fit: BoxFit.fitHeight,
            controller: _illustrationController,
          ),
        ),
        onHorizontalDragStart: (details) {
          final renderBox = context.findRenderObject() as RenderBox;

          final stringsStartX = renderBox.size.width * 3 / 12;
          final stringsEndX = renderBox.size.width * 7 / 12;
          final stringsStartY = renderBox.size.height / 4;
          final stringsEndY = renderBox.size.height * 3 / 4;

          final localPosition = details.localPosition;
          _stringsTouched = localPosition.dx > stringsStartX &&
              localPosition.dx < stringsEndX &&
              localPosition.dy > stringsStartY &&
              localPosition.dy < stringsEndY;
        },
        onHorizontalDragEnd: (details) {
          if (!_illustrationController.isActive.value &&
              details.velocity.pixelsPerSecond.dx > 0.0 &&
              _stringsTouched) {
            _stringsTouched = false;

            _illustrationController.play("start");
            _player
              ..setAsset("assets/sounds/lyre.mp3")
              ..play();
          }
        },
      );
}
