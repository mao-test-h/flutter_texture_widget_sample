import Flutter
import Foundation

public final class SwiftSampleVideoPlayerPlugin: NSObject {

    /// FlutterPluginより取得可能なテクスチャの管理クラス
    ///
    /// NOTE: iOSはこのクラスに対して「登録」「登録解除」「更新命令」などの呼び出しを行う
    private let textureRegistry: FlutterTextureRegistry

    /// 登録したtextureId, 生成済みのプレイヤー
    private var createdPlayers = [Int64: VideoPlayer]()

    init(with registrar: FlutterPluginRegistrar) {
        textureRegistry = registrar.textures()
        super.init()
    }

    deinit {
        // 後片付け
        for player in createdPlayers.values {
            player.dispose()
        }
        createdPlayers.removeAll()
    }

    /// プレイヤーの生成
    func createPlayer() -> Int64 {
        // NOTE:
        // プレイヤー内部でテクスチャの「登録、登録解除、更新命令」を呼び出せるように`textureRegistry`のインスタンスを渡しとく
        let player = VideoPlayer(with: textureRegistry)
        let textureId = player.textureId
        createdPlayers[textureId] = player
        return textureId
    }

    /// プレイヤーの破棄
    ///
    /// - Parameter textureId: 紐付いているtextureId
    func disposePlayer(with textureId: Int64) {
        guard let player = createdPlayers[textureId] else {
            return
        }

        player.dispose()
        createdPlayers[textureId] = nil
    }

    /// 再生する動画URLの指定
    ///
    /// - Parameters:
    ///   - textureId: 紐付いているtextureId
    ///   - hlsUrl: hls形式の動画URL
    func setUrl(with textureId: Int64, hlsUrl: String) {
        guard let player = createdPlayers[textureId] else {
            return
        }

        player.setUrl(with: hlsUrl)
    }

    /// プレイヤーの再生
    ///
    /// - Parameter textureId: 紐付いているtextureId
    func play(with textureId: Int64) {
        guard let player = createdPlayers[textureId] else {
            return
        }

        player.play()
    }

    /// プレイヤーの一時停止
    ///
    /// - Parameter textureId: 紐付いているtextureId
    func pause(with textureId: Int64) {
        guard let player = createdPlayers[textureId] else {
            return
        }

        player.pause()
    }
}
