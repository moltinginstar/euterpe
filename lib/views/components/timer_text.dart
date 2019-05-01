import "dart:ui";

import "package:euterpe/blocs/blocs.dart";
import "package:euterpe/utils/utils.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final elapsedTime = formatTime(
      timeInMillis: context.select((TimerBloc bloc) => bloc.state.elapsedTime),
    );

    return RichText(
      maxLines: 1,
      textAlign: TextAlign.center,
      text: TextSpan(
        style: Theme.of(context).textTheme.headline5!.copyWith(
          fontFeatures: [const FontFeature.tabularFigures()],
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: elapsedTime[0]),
          TextSpan(
            text: elapsedTime[1],
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
          ),
        ],
      ),
    );
  }
}
