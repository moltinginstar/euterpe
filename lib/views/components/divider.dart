import "package:euterpe/res/res.dart";
import "package:euterpe/utils/utils.dart";
import "package:flare_flutter/flare_actor.dart";
import "package:flutter/material.dart";

class Divider extends StatelessWidget {
  const Divider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        height: ResDimens.dividerHeight,
        margin: const EdgeInsets.symmetric(vertical: ResDimens.dividerMargin),
        child: FlareActor(
          "assets/animations/divider_${getThemeString(context)}.flr",
          animation: "start",
          fit: BoxFit.scaleDown,
        ),
      );
}
