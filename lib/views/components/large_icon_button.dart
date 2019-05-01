import "package:euterpe/res/res.dart";
import "package:flutter/material.dart";

class LargeIconButton extends StatefulWidget {
  final Color color;
  final Color highlightColor;
  final Color shadowColor;

  final IconData icon;
  final Color iconColor;

  final Function() onPressed;

  LargeIconButton({
    Key? key,
    this.color = Colors.white,
    this.highlightColor = Colors.black12,
    this.shadowColor = Colors.black54,
    required this.icon,
    this.iconColor = Colors.black,
    required this.onPressed,
  }) : super(key: key);

  @override
  _LargeIconButtonState createState() => _LargeIconButtonState();
}

class _LargeIconButtonState extends State<LargeIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _elevationAnimation;

  _LargeIconButtonState();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 30),
      vsync: this,
    );
    _elevationAnimation = Tween(
      begin: ResDimens.largeIconButtonElevation,
      end: ResDimens.largeIconButtonPressedElevation,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (details) => _animationController.forward(),
        onTapUp: (details) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: Container(
          width: ResDimens.largeIconButtonSize,
          height: ResDimens.largeIconButtonSize,
          alignment: Alignment.center,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => Material(
              color: widget.color,
              shadowColor: widget.shadowColor,
              shape: const CircleBorder(),
              elevation: _elevationAnimation.value,
              type: MaterialType.button,
              child: InkWell(
                highlightColor: widget.highlightColor,
                onTap: () => widget.onPressed(),
                borderRadius: BorderRadius.circular(
                  ResDimens.largeIconButtonSize,
                ),
                child: SizedBox(
                  width: ResDimens.largeIconButtonSize,
                  height: ResDimens.largeIconButtonSize,
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: ResDimens.largeIconButtonIconSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
