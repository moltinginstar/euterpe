import "dart:async";
import "dart:ui";

import "package:euterpe/utils/utils.dart";
import "package:euterpe/views/routes/top_snackbar_route.dart";
import "package:flutter/material.dart";

class TopSnackbar<T extends Object> extends StatefulWidget {
  late final TopSnackbarRoute<T>? _topSnackbarRoute;

  late final TopSnackbarStatusCallback? onStatusChanged;
  final Text? title;
  final Text? message;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadows;
  final Duration? duration;
  final double borderRadius;
  final TextField? textField;
  final Curve forwardAnimationCurve;
  final Curve reverseAnimationCurve;
  final Duration animationDuration;
  final Color overlayColor;

  bool get isShowing =>
      _topSnackbarRoute?.currentStatus == TopSnackbarStatus.completed;

  bool get isDismissed =>
      _topSnackbarRoute?.currentStatus == TopSnackbarStatus.dismissed;

  TopSnackbar({
    Key? key,
    this.title,
    this.message,
    this.textField,
    this.borderRadius = 0.0,
    this.backgroundColor = const Color(0xFF303030),
    this.boxShadows,
    this.duration,
    this.forwardAnimationCurve = Curves.easeOutCubic,
    this.reverseAnimationCurve = Curves.easeInCubic,
    this.animationDuration = const Duration(seconds: 1),
    TopSnackbarStatusCallback? onStatusChanged,
    this.overlayColor = Colors.transparent,
  })  : assert(textField != null || message != null),
        super(key: key) {
    this.onStatusChanged = onStatusChanged ?? (status) {};
  }

  Future<T?> show(BuildContext context) async {
    _topSnackbarRoute = TopSnackbarRoute(topSnackbar: this);

    return await Navigator.of(context).push(_topSnackbarRoute!);
  }

  Future<T?> dismiss([T? result]) async {
    if (_topSnackbarRoute == null) {
      return null;
    }

    if (_topSnackbarRoute!.isCurrent) {
      _topSnackbarRoute!.navigator!.pop(result);

      return _topSnackbarRoute!.completed;
    } else if (_topSnackbarRoute!.isActive) {
      _topSnackbarRoute!.navigator!.removeRoute(_topSnackbarRoute!);
    }

    return null;
  }

  @override
  State createState() => _TopSnackbarState<T>();
}

class _TopSnackbarState<K extends Object> extends State<TopSnackbar> {
  TopSnackbarStatus? currentStatus;

  late FocusScopeNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusScopeNode();
  }

  @override
  Widget build(BuildContext context) => Material(
        type: MaterialType.transparency,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            boxShadow: widget.boxShadows,
            borderRadius: BorderRadius.vertical(
              top: Radius.zero,
              bottom: Radius.circular(widget.borderRadius),
            ),
          ),
          child: widget.textField != null
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    top: 16.0,
                    right: 8.0,
                    bottom: 8.0,
                  ),
                  child: FocusScope(
                    child: widget.textField!,
                    node: _focusNode,
                    autofocus: true,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: MediaQuery.of(context).viewPadding.top,
                          ),
                          if (widget.title != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                top: 16.0,
                                right: 16.0,
                              ),
                              child: widget.title,
                            ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 16.0,
                              top: widget.title != null ? 6.0 : 16.0,
                              right: 16.0,
                              bottom: 16.0,
                            ),
                            child: widget.message,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      );
}
