import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sample_video_player/sample_video_player.dart';

/// 実装サンプル: ViewModel
class ExampleViewModel extends ChangeNotifier {
  // サンプルで再生するHLSの動画URL(固定)
  final _hlsUrl =
      'http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8';

  // 生成したプレイヤー
  final createdPlayers = <SampleVideoPlayer>[];

  @override
  void dispose() {
    for (var i = 0; i < createdPlayers.length; ++i) {
      createdPlayers[i].dispose();
    }
    super.dispose();
  }

  /// プレイヤーの追加
  Future addPlayer() async {
    final player = SampleVideoPlayer();
    await player.initialize();
    await player.setUrl(_hlsUrl);
    createdPlayers.add(player);
    notifyListeners();
  }

  /// プレイヤーの削除
  Future removePlayer() async {
    final index = createdPlayers.length - 1;
    if (index < 0) return;

    final player = createdPlayers[index];
    await player.dispose();
    createdPlayers.removeAt(index);
    notifyListeners();
  }
}
