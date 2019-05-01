import "package:euterpe/res/res.dart";
import "package:flutter/material.dart";

class TabTitle extends StatelessWidget {
  final String title;

  const TabTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: ResDimens.largeTitleVerticalMargin,
          horizontal: ResDimens.largeTitleHorizontalMargin,
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.headline1,
        ),
      );
}
