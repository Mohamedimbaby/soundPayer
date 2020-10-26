import 'package:audio_manager_example/Waves/painter/waveform_data_model.dart';
import 'package:flutter/services.dart';

Future<WaveformData> loadWaveformData(String filename) async {
  final data = await rootBundle.loadString("assets/$filename");
  return WaveformData.fromJson(data);
}
