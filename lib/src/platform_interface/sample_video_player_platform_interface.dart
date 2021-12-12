import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sample_video_player/src/sample_video_player_method_channel.dart';

/// 動画プレイヤー実装サンプル: PlatformInterface 実装部分
///
/// NOTE:
/// - ちゃんとやるならFederated pluginsの形式でプロジェクトを「実装部」と「インターフェース部」で分けておくのが良いのかもしれないが、
///   あくまでモバイル向けのサンプル実装なのでプロジェクトを分けずに管理してる。
/// - 説明しやすいようにpigeonなどは使わずに手動で定義している。
abstract class SampleVideoPlayerPlatforminterface extends PlatformInterface {
  //#region PlatformInterface

  SampleVideoPlayerPlatforminterface() : super(token: _token);

  static final Object _token = Object();

  static SampleVideoPlayerPlatforminterface _instance =
      SampleVideoPlayerMethodChannel();

  static SampleVideoPlayerPlatforminterface get instance => _instance;

  static set instance(SampleVideoPlayerPlatforminterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  //#endregion

  /// ネイティブ側でプレイヤーの生成を行う
  ///
  /// 戻り値として返す[int]は「生成したプレイヤーの管理ID」及び、「TextureWidgetに渡すtextureId」として機能する
  ///
  /// NOTE: 内部的にプレイヤーの生成と共に、TextureWidgetで利用するtextureIdの登録を行う
  Future<int> createPlayer() {
    throw UnimplementedError('createPlayer() has not been implemented.');
  }

  /// ネイティブ側で生成したプレイヤーの破棄
  ///
  /// [textureId]に紐付かれたプレイヤーの破棄を行う
  ///
  /// NOTE: 内部的にプレイヤーの破棄と共に、TextureWidgetで利用するtextureIdの登録解除を行う
  Future disposePlayer(int textureId) {
    throw UnimplementedError('disposePlayer() has not been implemented.');
  }

  /// 再生する動画のURLを指定 (HLS形式のみ対応)
  ///
  /// [textureId]に紐付かれたプレイヤーに対し、[hlsUrl]で指定された動画URLを設定
  Future setUrl(int textureId, String hlsUrl) {
    throw UnimplementedError('setUrl() has not been implemented.');
  }

  /// プレイヤーの再生
  ///
  /// [textureId]に紐付かれたプレイヤーを再生する
  Future play(int textureId) {
    throw UnimplementedError('play() has not been implemented.');
  }

  /// プレイヤーの一時停止
  ///
  /// [textureId]に紐付かれたプレイヤーを一時停止
  Future pause(int textureId) {
    throw UnimplementedError('pause() has not been implemented.');
  }
}
