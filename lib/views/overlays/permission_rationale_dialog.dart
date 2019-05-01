import "package:easy_localization/easy_localization.dart";
import "package:euterpe/main.dart";
import "package:euterpe/res/res.dart";
import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";

class PermissionRationaleDialog extends StatefulWidget {
  final Permission permission;
  final String confirmLabel;
  final Function() onConfirm;

  const PermissionRationaleDialog({
    Key? key,
    required this.permission,
    required this.confirmLabel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _PermissionRationaleDialogState createState() =>
      _PermissionRationaleDialogState();
}

class _PermissionRationaleDialogState extends State<PermissionRationaleDialog> {
  var _title = "";
  var _text = "";

  @override
  void initState() {
    super.initState();

    if (widget.permission == Permission.microphone) {
      _title = ResStrings.permissionRationaleMicrophoneTitle;
      _text = ResStrings.permissionRationaleMicrophoneText;
    } else if (widget.permission == Permission.storage) {
      _title = ResStrings.permissionRationaleStorageTitle;
      _text = ResStrings.permissionRationaleStorageText;
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: lightTheme,
        child: Builder(
          builder: (context) => AlertDialog(
            title: Text(
              _title.tr(),
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResDimens.radius),
            ),
            content: Text(_text.tr()),
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
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  widget.confirmLabel,
                  style: Theme.of(context).textTheme.button,
                ),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.resolveWith(
                      (s) => Theme.of(context).accentColor.withOpacity(0.5)),
                ),
                onPressed: () {
                  widget.onConfirm();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
}
