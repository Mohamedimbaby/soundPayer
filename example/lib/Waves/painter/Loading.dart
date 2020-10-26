import 'package:audio_manager_example/Waves/painter/waveform_data_model.dart';
import 'package:audio_manager_example/Waves/painter/waveform_painter.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget{
  AsyncSnapshot<WaveformData> snapshot;
  double maxWidth ;
  int seconds ;
  bool isPressed ;
  double x_seek =-1.0;
  LoadingWidget({this.snapshot, this.maxWidth , this.seconds , this.isPressed , this.x_seek});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoadingWidgetState();
  }

}
class LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController (
        duration:  Duration(seconds: widget.seconds + 100), vsync: this);

  }


  var width ;

  @override
  Widget build(BuildContext context) {
     width = MediaQuery.of(context).size.width;
     if(widget.x_seek !=-1.0){
       controller.animateTo(widget.x_seek,duration: Duration(seconds: 1));
     }

    if (widget.isPressed  )
    {
      controller.forward();
    }
    else {
      controller.stop(canceled: true); // liza did this
    }
    final height = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        //Image.asset('assets/images/splash.png', height:height ,width: width,),
        Container(
          color: Colors.white,
          child: Center(
              child: Stack(children: <Widget>[
                    Row(
                      children: <Widget>[
                        CustomPaint(
                          size: Size(
                            width,
                            height,
                          ),
                          foregroundPainter: WaveformPainter(
                             widget.snapshot.data,
                            zoomLevel: 70,
                            startingFrame: widget.snapshot.data.frameIdxFromPercent(1.0),
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  widget.seconds !=-1 ?
                  ClipRect(clipper: CustomLoadingClip(controller.value), child: Row(
                    children: <Widget>[
                      CustomPaint(
                        size: Size(
                          widget.maxWidth ,
                          height,
                        ),
                        foregroundPainter: WaveformPainter(
                          widget.snapshot.data,
                          zoomLevel: 70,
                          startingFrame: widget.snapshot.data.frameIdxFromPercent(0),
                          color: Colors.black,
                        ),
                      ),
                    ],
                  )) :
                  Container(width: 0,height: 0,)
                ]),
              ),
        ),
      ],

    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
class CustomLoadingClip extends CustomClipper<Rect> {
  final double value;

  CustomLoadingClip(this.value);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0.0, 0.0, size.width * value, size.height);
  }

  @override
  bool shouldReclip(CustomLoadingClip oldClipper) {
    return true;
  }
}