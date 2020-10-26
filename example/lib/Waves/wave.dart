import 'package:audio_manager_example/Waves/painter/Loading.dart';
import 'package:audio_manager_example/Waves/painter/waveform_data_loader.dart';
import 'package:audio_manager_example/Waves/painter/waveform_data_model.dart';
import 'package:audio_manager_example/Waves/painter/waveform_painter.dart';
import 'package:flutter/material.dart';
import 'package:audio_manager_example/Waves/wave.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:path_provider/path_provider.dart';



class WavePage extends StatefulWidget {
  @override
  _WavePageState createState() => _WavePageState();
}

class _WavePageState extends State<WavePage> {
  String _platformVersion = 'Unknown';
  bool isPlaying = false;
  bool isStarted = false;
  Duration _duration;
  Duration _position;
  double _slider;
  double _sliderVolume;
  String _error;
  num curIndex = 0;
  PlayMode playMode = AudioManager.instance.playMode;
  buildWaves(
      BuildContext context
      ) {
    return FutureBuilder<WaveformData>(
      future: loadWaveformData("oneshot.json"),
      builder: (context, AsyncSnapshot<WaveformData> snapshot) {
        if (snapshot.hasData) {
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
                  color: Colors.white,
                  child:
                     !isStarted ?
                     Row(
                  children: <Widget>[
                    CustomPaint(
                      size: Size(
                        MediaQuery.of(context).size.width,
                        height,
                      ),
                      foregroundPainter: WaveformPainter(
                        snapshot.data,
                        zoomLevel: 70,
                        startingFrame: snapshot.data.frameIdxFromPercent(1.0),
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                )
                    :   GestureDetector(
                         onTapDown: (TapDownDetails details) => _onTapDown(details),
                         child: LoadingWidget(snapshot: snapshot, maxWidth: constraints.maxWidth,seconds: _duration !=null ?  _duration.inSeconds : -1,isPressed : isPressed ,x_seek: secondsFromOffset, )) ,
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
        } else if (snapshot.hasError) {
          return Text("Error ${snapshot.error}", style: TextStyle(color: Colors.red));
        }
        return CircularProgressIndicator();
      },
    );
    /*const barWidth = 5.0;
    double bar1Position = 0;
    double bar2Position = 1.0;
    List<int> bars = [];

    Random r = Random();
    for (var i = 0; i < 70; i++) {
      bars.add(r.nextInt(100));
    }
    int i = 0;
    return SingleChildScrollView(
      child: Row(
        children: bars.map((int height) {
          Color color =
          i >= bar1Position / barWidth && i <= bar2Position / barWidth
              ? Color(0xFF1C68AF)
              : Colors.white ;
          i++;

          return Container(
            color: color,
            height: height.toDouble(),
            width: 5.0,
          );
        }).toList(),
      ),
    );*/

  }
  bool isSeeked =false;
  double getSecondsFromOffset(){

    if(x_seek != -1.0) {
      var result = (x_seek / width) * _duration.inSeconds;
        if(!isSeeked)
      {AudioManager.instance.seekTo(Duration(seconds: result.toInt()));
      isSeeked=true;
      return result + 25;
      }
    return -1;
    }else  {
      return -1;
    }
  }
  double x_seek = -1.0;
   _onTapDown(TapDownDetails details) {
     isSeeked = false ;
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    // or user the local position method to get the offset
    print(details.localPosition);
    print("tap down " + x.toString() + ", " + y.toString());
    x_seek = x ;
    secondsFromOffset = getSecondsFromOffset();
  }
  var secondsFromOffset = -1.0;
  _onTapUp(TapUpDetails details) {
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    // or user the local position method to get the offset
    print(details.localPosition);
    print("tap up " + x.toString() + ", " + y.toString());
  }
  final list = [
    {
      "title": "Assets",
      "desc": "local assets playback",
      "url": "assets/audio1.mp3",
      "coverUrl": "assets/ic_launcher.png"
    },
    {
      "title": "network",
      "desc": "network resouce playback",
      "url": "https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.m4a",
      "coverUrl": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png"
    }
  ];


  bool isPressed = false ;
  @override
  void initState() {
    super.initState();

    initPlatformState();
    setupAudio();
    // loadFile();
  }

  @override
  void dispose() {
    AudioManager.instance.stop();
    super.dispose();
  }

  void

  setupAudio() {
    List<AudioInfo> _list = [];
    list.forEach((item) => _list.add(AudioInfo(item["url"],
        title: item["title"], desc: item["desc"], coverUrl: item["coverUrl"])));

    AudioManager.instance.audioList = _list;
    AudioManager.instance.intercepter = true;
    AudioManager.instance.play(auto: false);

    AudioManager.instance.onEvents((events, args) {
      print("$events, $args");
      switch (events) {
        case AudioManagerEvents.start:
          print("start load data callback, curIndex is ${AudioManager.instance.curIndex}");
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          _slider = 0;
          setState(() {});
          break;
        case AudioManagerEvents.ready:
          print("ready to play");
          _error = null;
          _sliderVolume = AudioManager.instance.volume;
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          setState(() {});
          // if you need to seek times, must after AudioManagerEvents.ready event invoked
          // AudioManager.instance.seekTo(Duration(seconds: 10));
          break;
        case AudioManagerEvents.seekComplete:
          _position = AudioManager.instance.position;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          setState(() {});
          print("seek event is completed. position is [$args]/ms");
          break;
        case AudioManagerEvents.buffering:
          print("buffering $args");
          break;
        case AudioManagerEvents.playstatus:
          isPlaying = AudioManager.instance.isPlaying;
          setState(() {});
          break;
        case AudioManagerEvents.timeupdate:
          _position = AudioManager.instance.position;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          setState(() {});
          AudioManager.instance.updateLrc(args["position"].toString());
          break;
        case AudioManagerEvents.error:
          _error = args;
          setState(() {});
          break;
        case AudioManagerEvents.ended:
          AudioManager.instance.next();
          break;
        case AudioManagerEvents.volumeChange:
          _sliderVolume = AudioManager.instance.volume;
          setState(() {});
          break;
        default:
          break;
      }
    });
  }

  void loadFile() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    // Please make sure the `test.mp3` exists in the document directory
    final file = File("${appDocDir.path}/test.mp3");
    AudioInfo info = AudioInfo("file://${file.path}",
        title: "file",
        desc: "local file",
        coverUrl: "https://homepages.cae.wisc.edu/~ece533/images/baboon.png");

    list.add(info.toJson());
    AudioManager.instance.audioList.add(info);
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await AudioManager.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }
var width ;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin audio player'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: volumeFrame(),
              ),
              Expanded(
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(list[index]["title"],
                            style: TextStyle(fontSize: 18)),
                        subtitle: Text(list[index]["desc"]),
                        onTap: () => AudioManager.instance.play(index: index),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(),
                    itemCount: list.length),
              ),
              Center(
                  child: Text(_error != null
                      ? _error
                      : "${AudioManager.instance.info.title} lrc text: $_position")),
              buildWaves(context),
              bottomPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomPanel() {
    return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: songProgress(context),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                    icon: getPlayModeIcon(playMode),
                    onPressed: () {
                      playMode = AudioManager.instance.nextMode();
                      setState(() {});
                    }),
                IconButton(
                    iconSize: 36,
                    icon: Icon(
                      Icons.skip_previous,
                      color: Colors.black,
                    ),
                    onPressed: () => AudioManager.instance.previous()),
                IconButton(
                  onPressed: () async {
                    bool playing = await AudioManager.instance.playOrPause();
                    print("await -- $playing");
                    setState(() {
                      isStarted = true;
                      isPressed= !isPressed ;
                    });},
                  padding: const EdgeInsets.all(0.0),
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 48.0,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                    iconSize: 36,
                    icon: Icon(
                      Icons.skip_next,
                      color: Colors.black,
                    ),
                    onPressed: () => AudioManager.instance.next()),
                IconButton(
                    icon: Icon(
                      Icons.stop,
                      color: Colors.black,
                    ),
                    onPressed: () => AudioManager.instance.stop()),
              ],
            ),
          ),
        ]);
  }

  Widget getPlayModeIcon(PlayMode playMode) {
    switch (playMode) {
      case PlayMode.sequence:
        return Icon(
          Icons.repeat,
          color: Colors.black,
        );
      case PlayMode.shuffle:
        return Icon(
          Icons.shuffle,
          color: Colors.black,
        );
      case PlayMode.single:
        return Icon(
          Icons.repeat_one,
          color: Colors.black,
        );
    }
    return Container();
  }

  Widget songProgress(BuildContext context) {
    var style = TextStyle(color: Colors.black);
    return Row(
      children: <Widget>[
        Text(
          _formatDuration(_position),
          style: style,
        ),

        // wave


        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbColor: Color(0xFF1C68AF),
                  overlayColor: Color(0xFF1C68AF),
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5,
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: Color(0xFF1C68AF),
                  inactiveTrackColor:Color(0xFF1C68AF),
                ),
                child: Slider(
                  value: _slider ?? 0,
                  onChanged: (value) {
                    setState(() {
                      _slider = value;
                    });
                  },
                  onChangeEnd: (value) {
                    if (_duration != null) {
                      Duration msec = Duration(
                          milliseconds:
                          (_duration.inMilliseconds * value).round());
                      AudioManager.instance.seekTo(msec);
                    }
                  },
                )),
          ),
        ),
        Text(
          _formatDuration(_duration),
          style: style,
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }

  Widget volumeFrame() {
    return Row(children: <Widget>[
      IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(
            Icons.audiotrack,
            color: Colors.black,
          ),
          onPressed: () {
            AudioManager.instance.setVolume(0);
          }),
      Expanded(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Slider(
                value: _sliderVolume ?? 0,
                onChanged: (value) {
                  setState(() {
                    _sliderVolume = value;
                    AudioManager.instance.setVolume(value, showVolume: true);
                  });
                },
              )))
    ]);
  }
}