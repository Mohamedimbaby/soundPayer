import 'package:audio_manager_example/Waves/painter/painted_waveform.dart';
import 'package:audio_manager_example/Waves/painter/waveform_data_loader.dart';
import 'package:audio_manager_example/Waves/painter/waveform_data_model.dart';
import 'package:flutter/material.dart';

class PainterView extends StatelessWidget {
  const PainterView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //
      //
      body: Center(
        child: FutureBuilder<WaveformData>(
          future: loadWaveformData("oneshot.json"),
          builder: (context, AsyncSnapshot<WaveformData> snapshot) {
            if (snapshot.hasData) {
              return PaintedWaveform(sampleData: snapshot.data);
            } else if (snapshot.hasError) {
              return Text("Error ${snapshot.error}", style: TextStyle(color: Colors.red));
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
