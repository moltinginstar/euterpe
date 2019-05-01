import "dart:math";

import "package:euterpe/res/res.dart";
import "package:flutter/material.dart";

class VisualizerPainter extends CustomPainter {
  static const _bitDepth = 16; // Hardcoded for now
  static final _max = pow(2, _bitDepth - 1).toDouble() / 2;

  final List<double> data;
  late final double percent;
  final double barWidth;

  final Paint? _paint;
  final Paint? _backgroundPaint;

  VisualizerPainter.recorder({
    required this.data,
    required this.barWidth,
    required color,
  })  : _paint = Paint()
          ..isAntiAlias = true
          ..color = color,
        _backgroundPaint = null;

  VisualizerPainter.player({
    required this.data,
    required this.percent,
    required this.barWidth,
    required color,
    required backgroundColor,
  })  : _paint = Paint()
          ..isAntiAlias = true
          ..color = color,
        _backgroundPaint = Paint()
          ..isAntiAlias = true
          ..color = backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width != 0.0) {
      if (_backgroundPaint == null) {
        _paintRecorder(canvas, size);
      } else {
        _paintPlayer(canvas, size);
      }
    }
  }

  @override
  bool shouldRepaint(VisualizerPainter oldDelegate) {
    if (oldDelegate.data != data) {
      return true;
    }

    return false;
  }

  void _paintRecorder(Canvas canvas, Size size) {
    final maxBarCount = size.width ~/ (barWidth * 2);
    final newData = data.sublist(max(0, data.length - maxBarCount));
    final scaledData = newData.map((d) => (d / _max).clamp(0.02, 1.0)).toList();
    final middle = size.height / 2;
    for (var i = 0; i < scaledData.length; i++) {
      final x = size.width - (scaledData.length - i) * barWidth * 2;
      canvas.drawRRect(
        RRect.fromLTRBR(
          x - barWidth,
          middle + middle * scaledData[i],
          x,
          middle - middle * scaledData[i],
          const Radius.circular(ResDimens.visualizerBarRadius),
        ),
        _paint!,
      );
    }
  }

  void _paintPlayer(Canvas canvas, Size size) {
    final scaledData = data.map((d) => (d / _max).clamp(0.02, 1.0)).toList();
    final middle = size.height / 2;
    for (var i = 0; i < scaledData.length; i++) {
      final x = i * barWidth * 2;
      canvas.drawRRect(
        RRect.fromLTRBR(
          x,
          middle + middle * scaledData[i],
          x + barWidth,
          middle - middle * scaledData[i],
          const Radius.circular(ResDimens.visualizerBarRadius),
        ),
        i / scaledData.length * 100.0 < percent ? _paint! : _backgroundPaint!,
      );
    }
  }
}
