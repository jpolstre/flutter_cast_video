import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cast_video/flutter_cast_video.dart';

String duration2String(Duration? dur, {showLive = 'Live'}) {
  Duration duration = dur ?? Duration();
  if (duration.inSeconds < 0)
    return showLive;
  else {
    return duration.toString().split('.').first.padLeft(8, "0");
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CastSample());
  }
}

class CastSample extends StatefulWidget {
  static const _iconSize = 50.0;

  @override
  _CastSampleState createState() => _CastSampleState();
}

class _CastSampleState extends State<CastSample> {
  late ChromeCastController _controller;
  AppState _state = AppState.idle;
  bool _playing = false;
  Map<dynamic, dynamic> _mediaInfo = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plugin example app'),
        actions: <Widget>[
          AirPlayButton(
            size: CastSample._iconSize,
            color: Colors.white,
            activeColor: Colors.amber,
            onRoutesOpening: () => print('opening'),
            onRoutesClosed: () => print('closed'),
          ),
          ChromeCastButton(
            size: CastSample._iconSize,
            color: Colors.white,
            onButtonCreated: _onButtonCreated,
            onSessionStarted: _onSessionStarted,
            onSessionEnded: () => setState(() => _state = AppState.idle),
            onRequestCompleted: _onRequestCompleted,
            onRequestFailed: _onRequestFailed,
          ),
        ],
      ),
      body: Center(child: _handleState()),
    );
  }

  @override
  void dispose() {
    super.dispose();
    resetTimer();
  }

  Widget _handleState() {
    switch (_state) {
      case AppState.idle:
        resetTimer();
        return Text('ChromeCast not connected');
      case AppState.connected:
        return Text('No media loaded');
      case AppState.mediaLoaded:
        startTimer();
        return _mediaControls();
      case AppState.error:
        resetTimer();
        return Text('An error has occurred');
      default:
        return Container();
    }
  }

  Duration? position, duration;
  Widget _mediaControls() {
    return Column(children: [
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _RoundIconButton(
                icon: Icons.replay_10,
                onPressed: () =>
                    _controller.seek(relative: true, interval: -10.0),
              ),
              _RoundIconButton(
                  icon: _playing ? Icons.pause : Icons.play_arrow,
                  onPressed: _playPause),
              _RoundIconButton(
                icon: Icons.forward_10,
                onPressed: () =>
                    _controller.seek(relative: true, interval: 10.0),
              ),
            ],
          ),
          if (duration != null &&
              position != null &&
              duration!.inSeconds > position!.inSeconds)
            Slider(
              thumbColor: Colors.black,
              activeColor: Colors.black,
              inactiveColor: Colors.black.withOpacity(0.3),
              // divisions: 10,
              min: 0.0,
              label: "progress",
              max: duration!.inSeconds.toDouble(),
              value: position!.inSeconds.toDouble(),
              onChangeEnd: (val) {
                _controller.seek(relative: false, interval: val);
              },

              onChanged: (val) {},
            ),
        ],
      ),
      Text(duration2String(position) + '/' + duration2String(duration)),
      Text(jsonEncode(_mediaInfo)),
      SizedBox(height: 20),
      TextButton(onPressed: changeMedia, child: Text("change media"))
    ]);
  }

  Timer? _timer;

  Future<void> _monitor() async {
    // monitor cast events
    var dur = await _controller.duration(), pos = await _controller.position();
    if (duration == null || duration!.inSeconds != dur.inSeconds) {
      setState(() {
        duration = dur;
      });
    }
    if (position == null || position!.inSeconds != pos.inSeconds) {
      setState(() {
        position = pos;
      });
    }
  }

  void changeMedia() {
    position = null;
    duration = null;
    resetTimer();

    _controller.loadMedia(
        'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master2.m3u8',
        title: "TestTitle",
        subtitle: "test Sub title",
        image:
            "https://smaller-pictures.appspot.com/images/dreamstime_xxl_65780868_small.jpg");
  }

  void resetTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void startTimer() {
    if (_timer?.isActive ?? false) {
      return;
    }
    resetTimer();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _monitor();
    });
  }

  Future<void> _playPause() async {
    print("_playPause $_state");
    final playing = await _controller.isPlaying();
    if (playing == null) return;
    if (playing) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
    setState(() => _playing = !playing);
  }

  Future<void> _onButtonCreated(ChromeCastController controller) async {
    _controller = controller;
    await _controller.addSessionListener();
  }

  Future<void> _onSessionStarted() async {
    print("_onRequestCompleted $_state");
    setState(() => _state = AppState.connected);
    await _controller.loadMedia(
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        title: "TestTitle",
        subtitle: "test Sub title",
        image:
            "https://smaller-pictures.appspot.com/images/dreamstime_xxl_65780868_small.jpg");
  }

  Future<void> _onRequestCompleted() async {
    final playing = await _controller.isPlaying();
    if (playing == null) return;
    final mediaInfo = await _controller.getMediaInfo();
    setState(() {
      _state = AppState.mediaLoaded;
      _playing = playing;
      if (mediaInfo != null) {
        _mediaInfo = mediaInfo;
      }
      print("_onRequestCompleted $_state");
    });
  }

//revisar https://developers.google.com/android/reference/com/google/android/gms/cast/CastStatusCodes#FAILED, parasaber mas coodigos de error.
  Future<void> _onRequestFailed(String? errorCode) async {
    print(
        "_onRequestFailed---$errorCode"); //2100 Código de estado que indica que se produjo un error en la solicitud en curso.
    setState(() {
      if (errorCode == "2100") {
        _state = AppState.mediaLoaded;
      } else {
        _state = AppState.error;
      }
    });
    // print(error);
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  _RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: Icon(icon, color: Colors.black),
        // padding: EdgeInsets.all(16.0),
        // color: Colors.blue,
        // shape: CircleBorder(),
        onPressed: onPressed);
  }
}

enum AppState { idle, connected, mediaLoaded, error, errorMediaLoad }
