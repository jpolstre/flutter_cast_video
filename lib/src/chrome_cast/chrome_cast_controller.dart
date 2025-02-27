part of flutter_cast_video;

final ChromeCastPlatform _chromeCastPlatform = ChromeCastPlatform.instance;

enum MediaType {
  MEDIA_TYPE_GENERIC(0),
  MEDIA_TYPE_MOVIE(1),
  MEDIA_TYPE_TV_SHOW(2),
  MEDIA_TYPE_MUSIC_TRACK(3),
  MEDIA_TYPE_PHOTO(4),
  MEDIA_TYPE_AUDIOBOOK_CHAPTER(5),
  MEDIA_TYPE_USER(100);

  const MediaType(this.val);
  final int val;
}

/// Controller for a single ChromeCastButton instance running on the host platform.
class ChromeCastController {
  /// The id for this controller
  final int id;

  ChromeCastController._({required this.id});

  /// Initialize control of a [ChromeCastButton] with [id].
  static Future<ChromeCastController> init(int id) async {
    await _chromeCastPlatform.init(id);
    return ChromeCastController._(id: id);
  }

  /// Add listener for receive callbacks.
  Future<void> addSessionListener() {
    return _chromeCastPlatform.addSessionListener(id: id);
  }

  /// Remove listener for receive callbacks.
  Future<void> removeSessionListener() {
    return _chromeCastPlatform.removeSessionListener(id: id);
  }

  /// Load a new media by providing an [url].
  Future<void> loadMedia(
    String url, {
    String title = '',
    String subtitle = '',
    String image = '',
    bool? live,
    Map<String, String>? headers,
    MediaType? mediaType,
  }) {
    return _chromeCastPlatform.loadMedia(url, title, subtitle, image,
        id: id, live: live, headers: headers, mediaType: mediaType);
  }

  /// Plays the video playback.
  Future<void> play() {
    return _chromeCastPlatform.play(id: id);
  }

  /// Pauses the video playback.
  Future<void> pause() {
    return _chromeCastPlatform.pause(id: id);
  }

  /// If [relative] is set to false sets the video position to an [interval] from the start.
  ///
  /// If [relative] is set to true sets the video position to an [interval] from the current position.
  Future<void> seek({bool relative = false, double interval = 10.0}) {
    return _chromeCastPlatform.seek(relative, interval, id: id);
  }

  /// Set volume 0-1
  Future<void> setVolume({double volume = 0}) {
    return _chromeCastPlatform.setVolume(volume, id: id);
  }

  /// Get current volume
  Future<Map<dynamic, dynamic>?> getMediaInfo() {
    return _chromeCastPlatform.getMediaInfo(id: id);
  }

  /// Get current volume
  Future<double> getVolume() {
    return _chromeCastPlatform.getVolume(id: id);
  }

  /// Stop the current video.
  Future<void> stop() {
    return _chromeCastPlatform.stop(id: id);
  }

  /// Returns `true` when a cast session is connected, `false` otherwise.
  Future<bool?> isConnected() {
    return _chromeCastPlatform.isConnected(id: id);
  }

  /// End current session
  Future<void> endSession() {
    return _chromeCastPlatform.endSession(id: id);
  }

  /// Returns `true` when a cast session is playing, `false` otherwise.
  Future<bool?> isPlaying() {
    return _chromeCastPlatform.isPlaying(id: id);
  }

  /// Returns current position.
  Future<Duration> position() {
    return _chromeCastPlatform.position(id: id);
  }

  /// Returns video duration.
  Future<Duration> duration() {
    return _chromeCastPlatform.duration(id: id);
  }
}
