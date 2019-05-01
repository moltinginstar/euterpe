import "package:euterpe/res/res.dart";
import "package:euterpe/services/store.dart";
import "package:flutter/material.dart";

class BottomNavigationBar extends StatefulWidget {
  final int currentTab;
  final Function(int) onPressed;

  const BottomNavigationBar({
    Key? key,
    required this.currentTab,
    required this.onPressed,
  }) : super(key: key);

  @override
  _BottomNavigationBarState createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<BottomNavigationBar> {
  @override
  Widget build(BuildContext context) => Container(
        height: ResDimens.bottomNavigationBarHeight,
        margin: const EdgeInsets.only(
          left: ResDimens.bottomNavigationBarMargin,
          right: ResDimens.bottomNavigationBarMargin,
          bottom: ResDimens.bottomNavigationBarMargin,
        ),
        child: Material(
          shadowColor: const ResColors(Store.themeValueLight).shadowColor,
          color: const ResColors(Store.themeValueLight).secondaryColor,
          elevation: ResDimens.bottomNavigationBarElevation,
          borderRadius: BorderRadius.circular(ResDimens.radius),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.mic_none_outlined),
              const Icon(Icons.folder_outlined),
              const Icon(Icons.settings_outlined),
            ]
                .asMap()
                .map((index, icon) => MapEntry(
                      index,
                      IconButton(
                        icon: icon,
                        color: const ResColors(Store.themeValueLight)
                            .colorOnSecondary
                            .withOpacity(
                                widget.currentTab == index ? 1.0 : 0.38),
                        splashColor: Colors.transparent,
                        onPressed: () => widget.onPressed(index),
                      ),
                    ))
                .values
                .toList(),
          ),
        ),
      );
}
