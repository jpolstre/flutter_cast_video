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
            onRequestLoadMedia: _onRequestLoadMedia,
            onPlayerStatusUpdated: _onPlayerStatusUpdated,
          ),
        ],
      ),
      body: Center(child: _handleState()),
    );
  }

  final userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36';

  Map<String, String> get headers => {
        'sec-ch-ua':
            '"Chromium";v="106", "Google Chrome";v="106", "Not;A=Brand";v="99"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'cross-site',
        'User-Agent':
            userAgent, //'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36',
        'Pragma': 'no-cache', 'Connection': 'keep-alive',
        'Cache-Control': 'no-cache',
        // 'Origin': 'https://sbanh.com',
        // 'Referer': 'https://sbanh.com/',
        'Origin': 'https://sblongvu.com',
        'Referer': 'https://sblongvu.com/',
      };

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
      case AppState.error:
      case AppState.errorMediaLoad:
        return Column(
          children: [
            SizedBox(height: 24),
            if (_state == AppState.error || _state == AppState.errorMediaLoad)
              Text('An error has occurred'),
            SizedBox(height: 24),
            TextButton(
                onPressed: () => _loadMedia(
                      '"https://ffd6b8be926aef8829d33ff45c1e98486b885ff8ae277014f9bfa81-apidata.googleusercontent.com/download/storage/v1/b/bisco-01/o/5fabb1866dc51d7b5d8698b8.mp4?jk=Ac_6HjJHlT11QemYiZlGZsquSvO7ZtWDfUDCjFVkli21uPWO6YN25wAH8mwopEG-kJ8XiA3p00J_kbxLhcMN_PqlcxOH04tiLjCl0ycuzRGjL3qA6lrMOVPNyqrlO7JdFSPXQpCBWxOIlpE9Vrt56CaSeWshhvjKWDk_3ek-NnkhvBHM7O5vtnwjuNCvzTgkOWi0OoT9grL3cliW-MxmGfCl1JVzNW0rvO3u02paO-oKjxKf2FxQee-5BWFK2JPq69e0o8ec-O7N6nqYESPH6pFqBdXxkKVIFAx9FyEMAmTsIYf-oUpV8nToU2POaRws8zDqbbq79Q9a7DFnTdeaK8UENCRzZ7Rkzsi_4bRy1Xfp8dghEEpflQ2trEmxGgCQxppGs6TOfBUbU9OG-InrEn1tR6IRRfhS_xYcI_RtriNSHcw19bevbCx3cN5hfoL1sPz-QPP2ORido7w86SpIPHO-BKD2o91fySCOJV7McEKUabCCo_AzxA28v2FqwKH1NoCkz5CBZ0Cpv1HGornnjmwirxeKxL5itl4Rg8mWip8Jh6KSj-9HIpIf_5szeOlka1reO92aIgivbm5zzgaT-xqqf52wS_NIQGMlYO1q7SA9ALN9uzAh9bhhjDUU-ZBQH0bcJhP0y3CyiQ5cyDEi2iBeduj6V1cyX34za6v-VstJnNpTV1Yond4kiduopakdtubmwc_E6V90lofpsq1P0fFTZ7NLnvMfJFNIqnCJQnTvQLKomS7A1l5908yKZBXPaXhN8EvUBrrNDAOXaHUYa2YjiHcHIV2W6ihi1r507-tRxTz5cywq_OhhU2fIjF1ZF8MGsHRneoRGYTkN29_57VXx6222FUQ03yB_EOgjSADQYu_-tTeOFaiCczOmNh2rmpy-5Yt-5eCwtggehrHc3kpxNkKLL48lQQeX-LWZNBc4kBITC7dWqR6d-rtdWUXtCswolrzUBiXhUGbBXo8Vx1m-L5klNnbyR9pcW6MVFlqb0GKPeAvy4TW3RoeTj6pzj36I0yXHbPXum5KxOzS3JTcjtjGNCSJ7oP_AD4BWAohVEiYovYmk2brM1o243gBXgaQN0X2zJJ8xEC_nRPfTgn9uHyVFRgvv-qry2rd7M4-QoA2KsRPSTTMF6NCZMUKlXEEMLAnNfMZbp_ZH6JLvxVNWnsyb0l3jb3m1jEyNOBvKqRDi3r8GXdaqbnJQm5qMcfFlKbGM7aNA-CiwFw&isca=1',
                      title: "TestTitle",
                      subtitle: "test Sub title",
                      image:
                          "https://smaller-pictures.appspot.com/images/dreamstime_xxl_65780868_small.jpg",
                      headers: headers, //ok
                    ),
                child: Text("load media")),
            SizedBox(
              height: 24,
            ),
            TextButton(
                onPressed: () => _loadMedia(
                      'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
                      title: "TestTitle",
                      subtitle: "test Sub title",
                      // image:
                      //     "https://smaller-pictures.appspot.com/images/dreamstime_xxl_65780868_small.jpg",
                      image:
                          "https://image.tmdb.org/t/p/w185/dSAwFZkpOS2JMBujkfKcxcWwM3Y.jpg",
                      headers: headers,
                    ),
                child: Text("change media"))
          ],
        ); //Text('No media loaded');
      case AppState.mediaLoaded:
        startTimer();
        return _mediaControls();
      // case AppState.error:
      //   resetTimer();
      //   return Text('An error has occurred');

      // case AppState.errorMediaLoad:
      //   resetTimer();
      //   return Text('An error has occurred');
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
              if (_statusPlayer != StatusPlayer.finished.val)
                _RoundIconButton(
                    icon: _playing ? Icons.pause : Icons.play_arrow,
                    onPressed: _playPause)
              else
                _RoundIconButton(
                  icon: Icons.replay_outlined,
                  onPressed: () =>
                      _controller.seek(relative: false, interval: 0.0),
                ),
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
      if (_statusPlayer == StatusPlayer.buffering.val ||
          _statusPlayer == StatusPlayer.loading.val ||
          _statusPlayer == StatusPlayer.initLoading.val)
        LinearProgressIndicator(color: Colors.green),
      SizedBox(height: 20),
      TextButton(
          onPressed: () => _loadMedia(
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                title: "TestTitle",
                subtitle: "test Sub title",
                image:
                    "https://smaller-pictures.appspot.com/images/dreamstime_xxl_65780868_small.jpg",
                headers: headers,
              ),
          child: Text("load media")),
      SizedBox(height: 20),
      TextButton(
          onPressed: () => _loadMedia(
                'https://ff9ed356d26371a77c28c61f264979f5a8ce4f9bf9f29181112fa8d-apidata.googleusercontent.com/download/storage/v1/b/bisco-01/o/5fabb18c6dc51d7b5d8698bb.mp4?jk=ARTXCFGqHQ-WeEHjOHkvuTP8zA9mtSG1pQQamzljv66FhV2EnndXxTBxB63aIMAHO_B8ATxEjAavVhpTrK1G81NEKx3ekhncNaW1RqAt_K8wC0vhn_R6AUZVxEAgHJ0Uhrs9FEUW9zbm7zAE61-AT7d7iLxErZqEwTOx8uBYEvXA1gnIdkBjvwajpaWjNU1VdUDkkMur24ihr5h3fBfa6Hbwpbsvjx6UL2VZGIG0WFby8JReKSw7fG9csc-I3lioJPGCUSixIWh9WQBIEbffCzg9zKixkq5PaLuDWlx_reCCuHFCvqNIJtBbzJBD0tcdTZaaYxy4puHNrWbJJpKoqnAi_XAvPtGbiWEAf2Z_CJoxJqVZBbflca61Shgxe85-vhDy4vl7RczBHJHXVnfjyHzQqCAJTxJfPQTNxmcINGNUFiFthlADRchOxWxBOhTvit4Rm606wg5E9HkSHVXdPfK6SN4elX8ftFkgujQFdUpkrAWbqFylqU7Obx7HQBybvfVPxFFHtkXO1Crng82yl8sPbl0MfWfu3xMkafJwKj9oHgV03ERABBIduHjf7lZ3trKvdUm1JdlirnMKWI4oX6aSFhiiZSjxqxDcaDm6y6rLMh39wpR4Y0eQh6MNVlQR9Wx43A5T_Vya_VvJDpq175EvTbHFVw7vLrN-gCf-N0RoBV9nFswT6kQC6pDFojQwDNk_fbHP5pnpyfWTLv2JEeXLaguycQabqeqrO7ux9KsxVYg4AMVX5l7sDc06gdEyb9_AML4TbezIY4e7XfRe0GRJHMK-Wk9MzjyKvnQ6uy8f3XAZrUlCOqiW55b4t-R0dwGItsuqewllYpUIcDGzZCcMJRmxqXndoeAkYhRCJcOrZZ0bqtqKdJUP6ULfIsEEJgpUmqUb4lmwAeqXig6v8PQbo7sRbHDwSvyTCcl4tt0Q8XtqVS6HNWi43QBq8CkZuAZ_mK528RlbHBuisl0j7PTV4x2Y0aOSnHTXZIlb3wDTPZ2ReNLPKkDT74WiRDbGxRI1JU0bkFerNt3NSaT9qDS5D17CrGwjuaXRZ5SZV_hBYZIAsF-QO06P9MnkgfL3wVbKOw5Ngus5w-1uAG4LsLvVHHu-3OjHnuc2CdLQaY8M0_t3bG-D016ndYGJNhxNqsmxcLKBbMhe2lIKg67XeDijn3lYjbn-kM9Pqw4UNWpdAHsKuHaxQ2-FewPkXt1x_AtvTaZQcjwyIM_65g&isca=1',
                title: "TestTitle",
                subtitle: "test Sub title",
                image:
                    "https://smaller-pictures.appspot.com/images/dreamstime_xxl_65780868_small.jpg",
                // headers: headers,
              ),
          child: Text("change media"))
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

  String? currUrlMedia;
  Future<void> _loadMedia(String url,
      {required String title,
      required String subtitle,
      required String image,
      Map<String, String>? headers}) async {
    setState(() {
      _statusPlayer = StatusPlayer.initLoading.val;
    });
    position = null;
    duration = null;
    resetTimer();
    currUrlMedia = url;
    await _controller.loadMedia(
      url,
      title: title,
      subtitle: subtitle,
      image: image,
      headers: headers,
    );
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

    // await _loadMedia(
    //     'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    //     title: "TestTitle",
    //     subtitle: "test Sub title",
    //     image:
    //         "https://smaller-pictures.appspot.com/images/dreamstime_xxl_65780868_small.jpg");
  }

  var _statusPlayer = 4;
  Future<void> _onPlayerStatusUpdated(int? statusCode) async {
    // 1 = playing
    // 0 = buffering
    // 5 = loading
    // 2 = finished
    // 3 = paused
    // 4 = unknown
    print('statusCodexxx--->$statusCode');
    if (statusCode == StatusPlayer.finished.val) {
      _controller.pause();
    }
    setState(() {
      _statusPlayer = statusCode ?? 4;
    });
    // print('statusCode loading--->${statusCode == StatusPlayer.loading.val}');
  }

  Future<void> _onRequestLoadMedia(int? codeResult) async {
    print('_onRequestLoadMedia--->$codeResult');
    if (codeResult == 0) {
      final playing = await _controller.isPlaying();
      if (playing == null) return;
      final mediaInfo = await _controller.getMediaInfo();
      setState(() {
        _state = AppState.mediaLoaded;
        _playing = playing;
        if (mediaInfo != null) {
          _mediaInfo = mediaInfo;
        }
      });
    } else {
      setState(() {
        if (codeResult == 2100) {
          _state = AppState.errorMediaLoad;
        } else {
          _state = AppState.error;
        }
      });
    }
  }

  Future<void> _onRequestCompleted(int? codeOncomplete) async {
    // print('myCodeSucess--->$urlMedia');

    // if (urlMedia != null && currUrlMedia == urlMedia) {
    //   final playing = await _controller.isPlaying();
    //   if (playing == null) return;
    //   final mediaInfo = await _controller.getMediaInfo();
    //   setState(() {
    //     _state = AppState.mediaLoaded;
    //     _playing = playing;
    //     if (mediaInfo != null) {
    //       _mediaInfo = mediaInfo;
    //     }
    //     print("_onRequestCompleted $_state");
    //   });
    // }
  }

//revisar https://developers.google.com/android/reference/com/google/android/gms/cast/CastStatusCodes#FAILED, parasaber mas coodigos de error.
  Future<void> _onRequestFailed(int? errorCode) async {
    // print(
    //     "_onRequestFailed---$errorCode"); //2100 Código de estado que indica que se produjo un error en la solicitud en curso.
    // setState(() {
    //   if (errorCode == 2100) {
    //     _state = AppState.errorMediaLoad;
    //   } else {
    //     _state = AppState.error;
    //   }
    // });
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

// 1 = playing
// 0 = buffering
// 5 = loading
// 2 = finished
// 3 = paused
// 4 = unknown

enum AppState { idle, connected, mediaLoaded, error, errorMediaLoad }

enum StatusPlayer {
  playing(1),
  buffering(0),
  loading(5),
  finished(2),
  paused(3),
  unknown(4),
  initLoading(7);

  const StatusPlayer(this.val);
  final int val;
}
