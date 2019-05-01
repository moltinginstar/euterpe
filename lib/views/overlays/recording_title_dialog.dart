import "package:easy_localization/easy_localization.dart";
import "package:euterpe/main.dart";
import "package:euterpe/res/res.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class RecordingTitleDialog extends StatefulWidget {
  final String recordingTitle;

  const RecordingTitleDialog(
    this.recordingTitle, {
    Key? key,
  }) : super(key: key);

  @override
  _RecordingTitleDialogState createState() => _RecordingTitleDialogState();
}

class _RecordingTitleDialogState extends State<RecordingTitleDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.recordingTitle);
    _focusNode = FocusNode()
      ..addListener(() {
        if (_focusNode.hasFocus) {
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.text.length,
          );
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: lightTheme,
        child: Builder(
          builder: (context) => AlertDialog(
            title: Text(
              ResStrings.textRecordingTitle.tr(),
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResDimens.radius),
            ),
            content: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autocorrect: false,
              autofocus: true,
              cursorColor: Theme.of(context).accentColor,
              decoration: InputDecoration(
                hintText: ResStrings.textRecordingTitle.tr(),
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Theme.of(context).disabledColor),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(ResDimens.textFieldBorderRadius),
                  borderSide: BorderSide(
                    color: Theme.of(context).disabledColor,
                    width: ResDimens.textFieldBorderWidth,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(ResDimens.textFieldBorderRadius),
                  borderSide: BorderSide(
                    color: Theme.of(context).disabledColor,
                    width: ResDimens.textFieldBorderWidth,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(ResDimens.textFieldBorderRadius),
                  borderSide: BorderSide(
                    color: Theme.of(context).accentColor,
                    width: ResDimens.textFieldBorderWidth,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.all(ResDimens.textFieldPadding),
              ),
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.start,
              textCapitalization: TextCapitalization.sentences,
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  ResStrings.textCancel.tr(),
                  style: Theme.of(context).textTheme.button,
                ),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.resolveWith(
                      (s) => Theme.of(context).accentColor.withOpacity(0.5)),
                ),
                onPressed: () {
                  _controller.clear();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  ResStrings.textSave.tr(),
                  style: Theme.of(context).textTheme.button,
                ),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.resolveWith(
                      (s) => Theme.of(context).accentColor.withOpacity(0.5)),
                ),
                onPressed: () {
                  final text = _controller.text.replaceAll(RegExp("[/:]"), "-");
                  _controller.clear();
                  Navigator.of(context).pop(text);
                },
              ),
            ],
          ),
        ),
      );
}
