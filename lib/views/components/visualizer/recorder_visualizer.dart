import "package:euterpe/blocs/blocs.dart";
import "package:euterpe/res/res.dart";
import "package:euterpe/views/components/visualizer/visualizer_painter.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class RecorderVisualizer extends StatefulWidget {
  final double barWidth;
  final Color color;

  const RecorderVisualizer({
    Key? key,
    this.barWidth = ResDimens.visualizerBarWidth,
    required this.color,
  }) : super(key: key);

  @override
  _RecorderVisualizerState createState() => _RecorderVisualizerState();
}

class _RecorderVisualizerState extends State<RecorderVisualizer> {
  @override
  Widget build(BuildContext context) {
    final data = context.select((VisualizerBloc bloc) => bloc.state.waveform);

    return CustomPaint(
      painter: VisualizerPainter.recorder(
        data: data,
        barWidth: widget.barWidth,
        color: widget.color,
      ),
    );
  }
}
