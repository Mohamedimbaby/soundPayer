import 'package:audio_manager_example/Waves/painter/waveform_data_model.dart';
import 'package:audio_manager_example/Waves/painter/waveform_painter.dart';
import 'package:flutter/material.dart';

class PaintedWaveform extends StatefulWidget {
  PaintedWaveform({
    Key key,
    @required this.sampleData,
  }) : super(key: key);

  final WaveformData sampleData;

  @override
  _PaintedWaveformState createState() => _PaintedWaveformState();
}

class _PaintedWaveformState extends State<PaintedWaveform> {
  double startPosition = 1.0;
  double zoomLevel = 1.0;

  @override
  Widget build(context) {
    return Container(
      color: Colors.black87,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * .3,
      child: LayoutBuilder(
        builder: (context, BoxConstraints constraints) {
          var height;
          if (constraints.maxWidth < constraints.maxHeight) {
            height = 200.0;
          } else {
            height = 200.0;
          }

          return Container(
            child: Row(
              children: <Widget>[
                CustomPaint(
                  size: Size(
                    constraints.maxWidth,
                    height,
                  ),
                  foregroundPainter: WaveformPainter(
                    widget.sampleData,
                    zoomLevel: zoomLevel,
                    startingFrame: widget.sampleData.frameIdxFromPercent(startPosition),
                    color: Color(0xff3994DB),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      /* ListView(
        children: <Widget>[
          Flexible(
            child: Slider(
              activeColor: Colors.indigoAccent,
              min: 1.0,
              max: 95.0,
              divisions: 42,
              onChanged: (newzoomLevel) {
                setState(() => zoomLevel = newzoomLevel);
              },
              value: zoomLevel,
            ),
          ),
        ],
      ),*/
    );
  }
}
