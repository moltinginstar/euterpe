import "package:euterpe/res/res.dart";
import "package:euterpe/views/components/visualizer/visualizer_painter.dart";
import "package:flutter/material.dart";

class PlayerVisualizer extends StatefulWidget {
  final List<double> data;
  final double percent;
  final double barWidth;
  final Color color;
  final Color backgroundColor;

  const PlayerVisualizer({
    Key? key,
    required this.data,
    this.percent = 0.0,
    this.barWidth = ResDimens.visualizerBarWidth,
    required this.color,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  _PlayerVisualizerState createState() => _PlayerVisualizerState();
}

class _PlayerVisualizerState extends State<PlayerVisualizer> {
  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: VisualizerPainter.player(
          data: widget.data,
          percent: widget.percent,
          barWidth: widget.barWidth,
          color: widget.color,
          backgroundColor: widget.backgroundColor,
        ),
      );
}
