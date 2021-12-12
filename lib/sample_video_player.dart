import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sample_video_player/src/platform_interface/sample_video_player_platform_interface.dart';

final SampleVideoPlayerPlatforminterface _platformInterface =
    SampleVideoPlayerPlatforminterface.instance;

// textureId未登録状態
const int uninitializedTextureId = -1;

/// 動画プレイヤー実装サンプル
class SampleVideoPlayer {
  int _textureId = uninitializedTextureId;

  // 初期化完了待ち
  Completer? _initializeCompleter;

  //#region Public Method

  /// textureId (再生するTextureWidgetに渡すこと)
  int get textureId => _textureId;

  /// 初期化
  Future initialize() async {
    if (_textureId != uninitializedTextureId) {
      debugPrint('textureId登録済み');
      return;
    }

    _initializeCompleter = Completer<void>();
    _textureId = await _platformInterface.createPlayer();
    _initializeCompleter!.complete(null);
  }

  /// 破棄
  Future dispose() async {
    if (_textureId == uninitializedTextureId) {
      debugPrint('textureIdが未登録');
      return;
    }

    await _initializeCompleter!.future;
    await pause();
    await _platformInterface.disposePlayer(_textureId);
    _textureId = uninitializedTextureId;
    _initializeCompleter = null;
  }

  /// 再生する動画のURLを指定 (HLS形式のみ対応)
  Future setUrl(String hlsUrl) async {
    if (_textureId == uninitializedTextureId) {
      debugPrint('textureIdが未登録');
      return;
    }

    await _initializeCompleter!.future;
    await _platformInterface.setUrl(_textureId, hlsUrl);
  }

  /// 再生
  Future play() async {
    if (_textureId == uninitializedTextureId) {
      debugPrint('textureIdが未登録');
      return;
    }

    await _initializeCompleter!.future;
    await _platformInterface.play(_textureId);
  }

  /// 一時停止
  Future pause() async {
    if (_textureId == uninitializedTextureId) {
      debugPrint('textureIdが未登録');
      return;
    }

    await _initializeCompleter!.future;
    await _platformInterface.pause(_textureId);
  }

  //#endregion
}
