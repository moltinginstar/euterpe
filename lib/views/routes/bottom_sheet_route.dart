import "dart:async";

import "package:euterpe/res/res.dart";
import "package:euterpe/services/store.dart";
import "package:euterpe/utils/utils.dart";
import "package:euterpe/views/overlays/bottom_sheet.dart";
import "package:flutter/material.dart" hide BottomSheet;

class BottomSheetRoute extends PopupRoute<void> {
  String title;
  List<String> items;
  bool itemsAreKeys;
  Function(String)? onTap;

  List<Function()>? onTaps;

  late Widget _bottomSheet;
  late double _height;

  AnimationController? _animationController;
  late Animation<double> _fadeAnimation1;
  late Animation<double> _elevationAnimation;
  late Animation<double> _marginAnimation;
  late Animation<double> _heightAnimation;
  late Animation<double> _fadeAnimation2;

  late Function() _fadeAnimation1ForwardListener;
  late Function() _marginAnimationForwardListener;
  late Function() _heightAnimationForwardListener;
  late Function() _fadeAnimation2ForwardListener;
  late Function() _fadeAnimation1ReverseListener;
  late Function() _marginAnimationReverseListener;
  late Function() _heightAnimationReverseListener;
  late Function() _fadeAnimation2ReverseListener;

  late BottomSheetStatus currentStatus;
  Function(BottomSheetStatus status) onStatusChanged;

  bool get hasElevation => ![
        BottomSheetStatus.appearing,
        BottomSheetStatus.forward,
        BottomSheetStatus.disappearing,
        BottomSheetStatus.disappeared,
        BottomSheetStatus.dismissed,
      ].contains(currentStatus);

  final _transitionCompleter = Completer();

  Future get completed => _transitionCompleter.future;

  @override
  Animation<double> get animation => _animationController!;

  @override
  Animation<double> get secondaryAnimation => _animationController!;

  @override
  Color get barrierColor => Colors.black26;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  bool get finishedWhenPopped =>
      _animationController!.status == AnimationStatus.dismissed;

  @override
  bool get maintainState => false;

  @override
  bool get opaque => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 600);

  BottomSheetRoute({
    required this.title,
    required this.items,
    this.itemsAreKeys = true,
    this.onTap,
    this.onTaps,
    required this.onStatusChanged,
  });

  @override
  void install() {
    _bottomSheet = BottomSheet(
      title: title,
      items: items,
      itemsAreKeys: itemsAreKeys,
      onTap: onTap,
      onTaps: onTaps,
    );
    _height = ResDimens.smallTitleFontSize +
        2 * (ResDimens.smallTitleMargin + 2.0) +
        items.length * 56.0;

    _fadeAnimation1ForwardListener = () {
      if (_fadeAnimation1.value > 0.0 &&
          _fadeAnimation1.value < 1.0 &&
          currentStatus != BottomSheetStatus.appearing) {
        currentStatus = BottomSheetStatus.appearing;
        onStatusChanged(currentStatus);

        changedInternalState();
      } else if (_fadeAnimation1.value == 1.0 &&
          currentStatus != BottomSheetStatus.appeared) {
        currentStatus = BottomSheetStatus.appeared;
        onStatusChanged(currentStatus);

        changedInternalState();

        _fadeAnimation1.removeListener(_fadeAnimation1ForwardListener);
      }
    };
    _marginAnimationForwardListener = () {
      if (_marginAnimation.value > 0.0 &&
          _marginAnimation.value < ResDimens.bottomNavigationBarMargin &&
          currentStatus != BottomSheetStatus.preexpanding) {
        currentStatus = BottomSheetStatus.preexpanding;
        onStatusChanged(currentStatus);

        changedInternalState();
      } else if (_marginAnimation.value == 0.0 &&
          currentStatus != BottomSheetStatus.preexpanded) {
        currentStatus = BottomSheetStatus.preexpanded;
        onStatusChanged(currentStatus);

        changedInternalState();

        _marginAnimation.removeListener(_marginAnimationForwardListener);
      }
    };
    _heightAnimationForwardListener = () {
      if (_heightAnimation.value > ResDimens.bottomNavigationBarHeight &&
          _heightAnimation.value < _height &&
          currentStatus != BottomSheetStatus.expanding) {
        currentStatus = BottomSheetStatus.expanding;
        onStatusChanged(currentStatus);

        changedInternalState();
      } else if (_heightAnimation.value == _height &&
          currentStatus != BottomSheetStatus.expanded) {
        currentStatus = BottomSheetStatus.expanded;
        onStatusChanged(currentStatus);

        changedInternalState();

        _heightAnimation.removeListener(_heightAnimationForwardListener);
      }
    };
    _fadeAnimation2ForwardListener = () {
      if (_fadeAnimation2.value > 0.0 &&
          _fadeAnimation2.value < 1.0 &&
          currentStatus != BottomSheetStatus.postexpanding) {
        currentStatus = BottomSheetStatus.postexpanding;
        onStatusChanged(currentStatus);

        changedInternalState();
      } else if (_fadeAnimation2.value == 1.0 &&
          currentStatus != BottomSheetStatus.postexpanded) {
        currentStatus = BottomSheetStatus.postexpanded;
        onStatusChanged(currentStatus);

        changedInternalState();

        _fadeAnimation2.removeListener(_fadeAnimation2ForwardListener);
      }
    };
    _fadeAnimation1ReverseListener = () {
      if (_fadeAnimation1.value > 0.0 &&
          _fadeAnimation1.value < 1.0 &&
          currentStatus != BottomSheetStatus.disappearing) {
        currentStatus = BottomSheetStatus.disappearing;
        onStatusChanged(currentStatus);

        changedInternalState();
      } else if (_fadeAnimation1.value == 0.0 &&
          currentStatus != BottomSheetStatus.disappeared) {
        currentStatus = BottomSheetStatus.disappeared;
        onStatusChanged(currentStatus);

        changedInternalState();

        _fadeAnimation1.removeListener(_fadeAnimation1ForwardListener);
      }
    };
    _marginAnimationReverseListener = () {
      if (_marginAnimation.value > 0.0 &&
          _marginAnimation.value < ResDimens.bottomNavigationBarMargin &&
          currentStatus != BottomSheetStatus.postcollapsing) {
        currentStatus = BottomSheetStatus.postcollapsing;
        onStatusChanged(currentStatus);

        changedInternalState();
      } else if (_marginAnimation.value == 0.0 &&
          currentStatus != BottomSheetStatus.postcollapsed &&
          ![
            BottomSheetStatus.reverse,
            BottomSheetStatus.precollapsing,
            BottomSheetStatus.precollapsed,
            BottomSheetStatus.collapsing,
            BottomSheetStatus.collapsed,
          ].contains(currentStatus)) {
        currentStatus = BottomSheetStatus.postcollapsed;
        onStatusChanged(currentStatus);

        changedInternalState();

        _marginAnimation.removeListener(_marginAnimationReverseListener);
      }
    };
    _heightAnimationReverseListener = () {
      if (_heightAnimation.value > ResDimens.bottomNavigationBarHeight &&
          _heightAnimation.value < _height &&
          currentStatus != BottomSheetStatus.collapsing) {
        currentStatus = BottomSheetStatus.collapsing;
        onStatusChanged(currentStatus);

        changedInternalState();
      } else if (_heightAnimation.value == _height &&
          currentStatus != BottomSheetStatus.collapsed &&
          ![
            BottomSheetStatus.reverse,
            BottomSheetStatus.precollapsing,
            BottomSheetStatus.precollapsed,
          ].contains(currentStatus)) {
        currentStatus = BottomSheetStatus.collapsed;
        onStatusChanged(currentStatus);

        changedInternalState();

        _heightAnimation.removeListener(_heightAnimationReverseListener);
      }
    };
    _fadeAnimation2ReverseListener = () {
      if (_fadeAnimation2.value > 0.0 &&
          _fadeAnimation2.value < 1.0 &&
          currentStatus != BottomSheetStatus.precollapsing) {
        currentStatus = BottomSheetStatus.precollapsing;
        onStatusChanged(currentStatus);

        changedInternalState();
      } else if (_fadeAnimation2.value == 0.0 &&
          currentStatus != BottomSheetStatus.precollapsed) {
        currentStatus = BottomSheetStatus.precollapsed;
        onStatusChanged(currentStatus);

        changedInternalState();

        _fadeAnimation2.removeListener(_fadeAnimation2ReverseListener);
      }
    };

    _animationController = AnimationController(
      duration: transitionDuration,
      vsync: navigator!,
    );
    _fadeAnimation1 = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(
        0.0,
        0.15,
        curve: Curves.decelerate,
      ),
    ));
    _elevationAnimation = Tween(
      begin: ResDimens.bottomNavigationBarElevation,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(
        0.15,
        0.4,
        curve: Curves.decelerate,
      ),
    ));
    _marginAnimation = Tween(
      begin: ResDimens.bottomNavigationBarMargin,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(
        0.15,
        0.4,
        curve: Curves.decelerate,
      ),
    ));
    _heightAnimation = Tween(
      begin: ResDimens.bottomNavigationBarHeight,
      end: _height,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(
        0.4,
        0.8,
        curve: Curves.decelerate,
      ),
    ));
    _fadeAnimation2 = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(
        0.8,
        1.0,
        curve: Curves.decelerate,
      ),
    ));

    super.install();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _transitionCompleter.complete();

    super.dispose();
  }

  @override
  // ignore: must_call_super
  TickerFuture didPush() {
    _animationController!.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          currentStatus = BottomSheetStatus.completed;
          onStatusChanged(currentStatus);

          break;
        case AnimationStatus.forward:
          currentStatus = BottomSheetStatus.forward;
          onStatusChanged(currentStatus);

          _fadeAnimation1.addListener(_fadeAnimation1ForwardListener);
          _marginAnimation.addListener(_marginAnimationForwardListener);
          _heightAnimation.addListener(_heightAnimationForwardListener);
          _fadeAnimation2.addListener(_fadeAnimation2ForwardListener);

          break;
        case AnimationStatus.reverse:
          currentStatus = BottomSheetStatus.reverse;
          onStatusChanged(currentStatus);

          _fadeAnimation1.addListener(_fadeAnimation1ReverseListener);
          _marginAnimation.addListener(_marginAnimationReverseListener);
          _heightAnimation.addListener(_heightAnimationReverseListener);
          _fadeAnimation2.addListener(_fadeAnimation2ReverseListener);

          break;
        case AnimationStatus.dismissed:
          currentStatus = BottomSheetStatus.dismissed;
          onStatusChanged(currentStatus);

          if (!isCurrent) {
            navigator!.finalizeRoute(this);
          }

          break;
      }

      changedInternalState();
    });

    return _animationController!.forward();
  }

  @override
  void didReplace(Route<dynamic>? oldRoute) {
    if (oldRoute is BottomSheetRoute) {
      _animationController!.value = oldRoute._animationController!.value;
    }

    super.didReplace(oldRoute);
  }

  @override
  bool didPop(void result) {
    _animationController!.reverse();

    return super.didPop(result);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      AnimatedBuilder(
        animation: _animationController!,
        builder: (context, widget) => Align(
          alignment: Alignment.bottomCenter,
          child: FadeTransition(
            opacity: _fadeAnimation1,
            child: Container(
              height: _heightAnimation.value,
              margin: EdgeInsets.only(
                left: _marginAnimation.value,
                right: _marginAnimation.value,
                bottom: _marginAnimation.value,
              ),
              child: Material(
                  shadowColor:
                      const ResColors(Store.themeValueLight).shadowColor,
                  color: const ResColors(Store.themeValueLight).secondaryColor,
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(ResDimens.radius),
                    bottom: Radius.circular(ResDimens.radius -
                        (ResDimens.bottomNavigationBarMargin * 4 -
                                _marginAnimation.value) /
                            (ResDimens.bottomNavigationBarMargin * 4) *
                            ResDimens.radius),
                  ),
                  elevation: hasElevation ? _elevationAnimation.value : 0.0,
                  child: FadeTransition(
                    opacity: _fadeAnimation2,
                    child: _bottomSheet,
                  )),
            ),
          ),
        ),
      );
}
