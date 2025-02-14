import 'component_interface.dart';
import '../ui_apis.dart';

class Image extends UIComponent {
  Image._create(super.id);

  static Future<Image?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('ImageView');
    return id != null ? Image._create(id) : null;
  }

  Future<Image> loadUrl(String url) async {
    await NativeUIBridge().updateView(id, {'url': url});
    return this;
  }

  Future<Image> loadAsset(String assetPath) async {
    await NativeUIBridge().updateView(id, {'asset': assetPath});
    return this;
  }

  Future<Image> loadSvg(String svgPath) async {
    await NativeUIBridge().updateView(id, {'svg': svgPath});
    return this;
  }

  Future<Image> contentMode(ImageContentMode mode) async {
    await NativeUIBridge().updateView(id, {'contentMode': mode.toString()});
    return this;
  }
}

enum ImageContentMode {
  scaleToFill,
  scaleAspectFit,
  scaleAspectFill,
  center,
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class Video extends UIComponent {
  Video._create(super.id);

  static Future<Video?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('VideoView');
    return id != null ? Video._create(id) : null;
  }

  Future<Video> loadUrl(String url) async {
    await NativeUIBridge().updateView(id, {'url': url});
    return this;
  }

  Future<Video> loadAsset(String assetPath) async {
    await NativeUIBridge().updateView(id, {'asset': assetPath});
    return this;
  }

  Future<Video> play() async {
    await NativeUIBridge().invokeMethod('playVideo', {'viewId': id});
    return this;
  }

  Future<Video> pause() async {
    await NativeUIBridge().invokeMethod('pauseVideo', {'viewId': id});
    return this;
  }

  Future<Video> seekTo(Duration position) async {
    await NativeUIBridge().invokeMethod('seekVideo', {
      'viewId': id,
      'position': position.inMilliseconds
    });
    return this;
  }

  Future<Video> setControls(bool show) async {
    await NativeUIBridge().updateView(id, {'showControls': show});
    return this;
  }

  Future<Video> onPlaybackStateChanged(Function(VideoPlaybackState) callback) async {
    await NativeUIBridge().registerEvent(id, 'onPlaybackStateChanged', (args) {
      final state = VideoPlaybackState.values[args['state'] as int];
      callback(state);
    });
    return this;
  }
}

enum VideoPlaybackState {
  playing,
  paused,
  stopped,
  buffering,
  finished,
  error,
}
