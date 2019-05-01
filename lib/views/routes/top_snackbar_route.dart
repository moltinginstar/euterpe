import "dart:async";

import "package:euterpe/utils/utils.dart";
import "package:euterpe/views/overlays/top_snackbar.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";

class TopSnackbarRoute<T> extends OverlayRoute<T> {
  TopSnackbar topSnackbar;

  AnimationController? _animationController;
  Animation<Alignment>? _alignmentAnimation;

  TopSnackbarStatus? currentStatus;
  TopSnackbarStatusCallback? _onStatusChanged;

  Timer? _timer;
  T? _result;

  final _transitionCompleter = Completer<T?>();

  Future<T?> get completed => _transitionCompleter.future;

  AnimationController get controller => _animationController!;

  Animation<Alignment> get animation => _alignmentAnimation!;

  bool get opaque => false;

  bool canTransitionTo(TopSnackbarRoute<dynamic> nextRoute) => true;

  bool canTransitionFrom(TopSnackbarRoute<dynamic> previousRoute) => true;

  @override
  bool get finishedWhenPopped =>
      _animationController!.status == AnimationStatus.dismissed;

  TopSnackbarRoute({
    required this.topSnackbar,
    RouteSettings? settings,
  }) : super(settings: settings) {
    _onStatusChanged = topSnackbar.onStatusChanged;
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() => [
        OverlayEntry(
          builder: (context) => GestureDetector(
            onTap: () => topSnackbar.dismiss(),
            child: Container(
              constraints: BoxConstraints.expand(),
              color: topSnackbar.overlayColor,
            ),
          ),
          maintainState: false,
          opaque: false,
        ),
        OverlayEntry(
          builder: (context) => Semantics(
            child: AlignTransition(
              alignment: _alignmentAnimation!,
              child: topSnackbar,
            ),
            focused: true,
            scopesRoute: true,
            explicitChildNodes: true,
          ),
          maintainState: false,
          opaque: opaque,
        )
      ];

  @override
  void install() {
    _animationController = AnimationController(
      duration: topSnackbar.animationDuration,
      vsync: navigator!,
    );
    _alignmentAnimation = AlignmentTween(
      begin: const Alignment(-1.0, -2.0),
      end: const Alignment(-1.0, -1.0),
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: topSnackbar.forwardAnimationCurve,
      reverseCurve: topSnackbar.reverseAnimationCurve,
    ));

    super.install();
  }

  @override
  // ignore: must_call_super
  TickerFuture didPush() {
    _alignmentAnimation!.addStatusListener(_handleStatusChanged);
    _configureTimer();

    return _animationController!.forward();
  }

  @override
  void didReplace(Route<dynamic>? oldRoute) {
    if (oldRoute is TopSnackbarRoute) {
      _animationController!.value = oldRoute._animationController!.value;
    }
    _alignmentAnimation!.addStatusListener(_handleStatusChanged);

    super.didReplace(oldRoute);
  }

  @override
  bool didPop(T? result) {
    _result = result;
    _cancelTimer();

    _animationController!.reverse();

    return super.didPop(result);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _transitionCompleter.complete(_result);

    super.dispose();
  }

  void _handleStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        currentStatus = TopSnackbarStatus.completed;
        _onStatusChanged!(currentStatus!);
        if (overlayEntries.isNotEmpty) {
          overlayEntries.first.opaque = opaque;
        }

        break;
      case AnimationStatus.forward:
        currentStatus = TopSnackbarStatus.forward;
        _onStatusChanged!(currentStatus!);

        break;
      case AnimationStatus.reverse:
        currentStatus = TopSnackbarStatus.reverse;
        _onStatusChanged!(currentStatus!);
        if (overlayEntries.isNotEmpty) {
          overlayEntries.first.opaque = false;
        }

        break;
      case AnimationStatus.dismissed:
        assert(!overlayEntries.first.opaque);
        currentStatus = TopSnackbarStatus.dismissed;
        _onStatusChanged!(currentStatus!);

        if (!isCurrent) {
          navigator!.finalizeRoute(this);
          if (overlayEntries.isNotEmpty) {
            overlayEntries.clear();
          }
          assert(overlayEntries.isEmpty);
        }

        break;
    }

    changedInternalState();
  }

  void _configureTimer() {
    if (topSnackbar.duration != null) {
      if (_timer != null && _timer!.isActive) {
        _timer!.cancel();
      }
      _timer = Timer(topSnackbar.duration!, () => topSnackbar.dismiss());
    } else {
      if (_timer != null) {
        _timer!.cancel();
      }
    }
  }

  void _cancelTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }
}
