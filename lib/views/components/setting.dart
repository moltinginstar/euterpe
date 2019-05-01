import "package:euterpe/res/res.dart";
import "package:flutter/material.dart";

class Setting extends StatefulWidget {
  final String title;
  final String summary;
  final Function()? onTap;

  const Setting({
    Key? key,
    required this.title,
    required this.summary,
    required this.onTap,
  }) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(
          widget.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        subtitle: Text(
          widget.summary,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.bodyText2,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ResDimens.mainPadding,
        ),
        onTap: widget.onTap,
      );
}
