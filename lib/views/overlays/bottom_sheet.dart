import "package:easy_localization/easy_localization.dart";
import "package:euterpe/res/res.dart";
import "package:euterpe/services/store.dart";
import "package:flutter/material.dart";

class BottomSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final bool itemsAreKeys;
  final Function(String)? onTap;
  final List<Function()>? onTaps;

  const BottomSheet({
    Key? key,
    required this.title,
    required this.items,
    required this.itemsAreKeys,
    this.onTap,
    this.onTaps,
  })  : assert(onTap != null || onTaps != null),
        super(key: key);

  @override
  _BottomSheetState createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheet> {
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(
              vertical: ResDimens.smallTitleMargin,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ResDimens.mainPadding + ResDimens.textFieldPadding,
              ),
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          ),
          ...widget.items
              .asMap()
              .map((index, item) => MapEntry(
                    index,
                    ListTile(
                      title: Text(
                        widget.itemsAreKeys ? item.tr() : item,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: const ResColors(Store.themeValueLight)
                                  .textColorOnSecondary,
                            ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: ResDimens.mainPadding,
                      ),
                      onTap: () {
                        if (widget.onTap != null) {
                          widget.onTap!(item);
                        } else {
                          widget.onTaps![index]();
                        }
                      },
                    ),
                  ))
              .values
              .toList(),
        ],
      );
}
