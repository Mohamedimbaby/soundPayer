import 'package:audio_manager_example/waveModel.dart';
import 'package:flutter/material.dart';
import 'dart:math';


class VibesTween extends Tween<Wave> {
  VibesTween(Wave begin, Wave end) : super(begin: begin, end: end);

  @override
  Wave lerp(double t) => Wave.lerp(begin, end, t);
}
class WavesPainter extends CustomPainter {

  WavesPainter(Animation<Wave> animation)
      : animation = animation,
        super(repaint: animation);

  final Animation<Wave> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = new Paint();
    canvas.translate(size.width / 2, size.height / 2);

    canvas.save();

    final radius = size.width / 2;
    final chart = animation.value;

    for (final wave in chart.wave)  {

      paint.color = wave.color;
      canvas.drawLine(
        new Offset(0.0, -radius),
        new Offset(1.0, -radius - (wave.height * 30)),
        paint,
      );
      canvas.drawRect(
        new Rect.fromLTRB(
            0.00, -radius, 2.00, -radius - (wave.height * 15)
        ),
        paint,
      );
      canvas.rotate(2 * pi / chart.wave.length);
   // canvas.drawLine(p1, p2, paint)
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(WavesPainter old) => true;
}
class Waves extends StatefulWidget {
    Duration duration ;
    Waves({this.duration});
  final state = new WavesState();
  @override
  WavesState createState() => state;


}

class WavesState extends State<Waves> with TickerProviderStateMixin {
  static const size = const Size(100.0, 5.0);
  final random = new Random();
  AnimationController animation;
  VibesTween tween;

  @override
  void initState() {
    super.initState();
    animation = new AnimationController(
      duration:  Duration(milliseconds: 100),
      vsync: this,
    );
    tween = new VibesTween(
      new Wave.empty(size),
      new Wave.random(size, random),
    );
    animation.forward();
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed)
      {
        setState(() {
          tween = new VibesTween(
            tween.evaluate(animation),
            new Wave.random(size, random),
          );
          animation.reverse();
        });
      }
      if (status == AnimationStatus.dismissed)
      {
        setState(() {
          tween = new VibesTween(
            tween.evaluate(animation),
            new Wave.random(size, random),
          );
          animation.forward();
        });
      }

    });
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  void changeWave() {
    setState(() {
      tween = new VibesTween(
        tween.evaluate(animation),
        new Wave.random(size, random),
      );
      animation.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      new Container(
        width: 330.00,
        height: 330.00,
        padding: const EdgeInsets.all(55.0),
        child: new CustomPaint(
          size: size,
          painter: new WavesPainter(tween.animate(animation)),
        ),
      );
  }
}