import "package:euterpe/models/models.dart";
import "package:euterpe/res/res.dart";
import "package:euterpe/services/store.dart";
import "package:euterpe/utils/utils.dart";
import "package:flutter/material.dart";

class RecordingCard extends StatefulWidget {
  final Recording recording;
  final Animation<double>? elevationAnimation;

  const RecordingCard({
    Key? key,
    required this.recording,
    required this.elevationAnimation,
  }) : super(key: key);

  @override
  _RecordingCardState createState() => _RecordingCardState();
}

class _RecordingCardState extends State<RecordingCard> {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
          left: ResDimens.recordingCardMargin,
          top: 4.0,
          right: ResDimens.recordingCardMargin,
          bottom: 16.0,
        ),
        child: Material(
          shadowColor: const ResColors(Store.themeValueLight).shadowColor,
          color: Theme.of(context).primaryColor,
          elevation: widget.elevationAnimation?.value ??
              ResDimens.recordingCardElevation,
          borderRadius: BorderRadius.circular(ResDimens.radius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.recording.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ResDimens.radius),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: ResDimens.recordingCardPadding,
                    top: ResDimens.recordingCardPadding,
                    right: ResDimens.recordingCardPadding,
                  ),
                  child: Text(
                    widget.recording.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: ResDimens.recordingCardPadding,
                    top: ResDimens.subtitleMargin,
                    right: ResDimens.recordingCardPadding,
                  ),
                  child: Text(
                    formatDate(context, widget.recording.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
