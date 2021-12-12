import 'package:flutter/services.dart';
import 'package:sample_video_player/src/platform_interface/sample_video_player_platform_interface.dart';

/// 動画プレイヤー実装サンプル: MethodChannel 実装部分
class SampleVideoPlayerMethodChannel
    implements SampleVideoPlayerPlatforminterface {
  final MethodChannel _methodChannel = const MethodChannel(
    'com.example.sample_video_player/method_channel',
  );

  @override
  Future<int> createPlayer() async {
    final textureId = await _methodChannel.invokeMethod<int>(
      'createPlayer',
    );
    assert(textureId != null);
    return textureId!;
  }

  @override
  Future disposePlayer(int textureId) async {
    return _methodChannel.invokeMethod(
      'disposePlayer',
      <String, dynamic>{
        'textureId': textureId,
      },
    );
  }

  @override
  Future setUrl(int textureId, String hlsUrl) {
    return _methodChannel.invokeMethod(
      'setUrl',
      <String, dynamic>{
        'textureId': textureId,
        'hlsUrl': hlsUrl,
      },
    );
  }

  @override
  Future play(int textureId) {
    return _methodChannel.invokeMethod(
      'play',
      <String, dynamic>{
        'textureId': textureId,
      },
    );
  }

  @override
  Future pause(int textureId) {
    return _methodChannel.invokeMethod(
      'pause',
      <String, dynamic>{
        'textureId': textureId,
      },
    );
  }
}
