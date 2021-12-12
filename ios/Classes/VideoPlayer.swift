import AVFoundation
import Flutter

/// 動画プレイヤー
///
/// AVPlayerをバックエンドに実装していく。
/// ※ もしバックエンドのプレイヤーを分けたいならprotocolを切るなりしても良いかも
final class VideoPlayer: NSObject {

    /// テクスチャ未登録時の値
    private static let uninitializedTextureId: Int64 = -1

    private let textureRegistry: FlutterTextureRegistry
    private var _textureId: Int64 = uninitializedTextureId

    // AVPlayer関連
    private let avPlayer: AVPlayer
    private let playerItemVideoOutput: AVPlayerItemVideoOutput
    private var currentItem: AVPlayerItem? = nil

    // 動画更新用
    private var displayLink: CADisplayLink! = nil

    // KVO登録管理
    private var kvoObservers = [NSKeyValueObservation]()

    /// 登録されたtextureId
    var textureId: Int64 {
        _textureId
    }

    // MARK:- Public Methods

    init(with registrar: FlutterTextureRegistry) {
        textureRegistry = registrar

        avPlayer = AVPlayer()
        playerItemVideoOutput = AVPlayerItemVideoOutput(
            pixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            ]
        )

        super.init()

        // textureIdの登録
        //
        // NOTE:
        // `register`に渡すクラスは`FlutterTexture`と言うprotocolを実装している必要がある。
        // → 今回の実装例ではVideoPlayer自身が`FlutterTexture`を実装している
        _textureId = textureRegistry.register(self)

        // リフレッシュレートに合わせてテクスチャの更新命令を呼び出すために登録
        let displayLink = CADisplayLink(target: self, selector: #selector(onDisplayLinkUpdate(_:)))
        displayLink.add(to: RunLoop.current, forMode: .default)
        displayLink.isPaused = true
        self.displayLink = displayLink
    }

    func dispose() {
        currentItem = nil

        displayLink.invalidate()
        displayLink = nil

        kvoObservers.forEach({ $0.invalidate() })
        kvoObservers.removeAll()

        // textureIdの登録解除
        textureRegistry.unregisterTexture(_textureId)
    }

    func setUrl(with hlsUrl: String) {
        let asset = AVAsset(url: URL(string: hlsUrl)!)
        let item = AVPlayerItem(asset: asset)
        avPlayer.replaceCurrentItem(with: item)
        avPlayer.actionAtItemEnd = .none

        // KVOにてAVPlayerItemのプロパティの状態変化を検知
        kvoObservers.append(
            item.observe(\.status, options: [.initial, .new]) { item, change in
                switch (item.status) {
                case .readyToPlay:
                    // 状態が`readyToPlay`になったらFlutter上で再生可能状態とする
                    item.add(self.playerItemVideoOutput)
                    break
                case .failed:
                    print("failed to load video: \(item.error?.localizedDescription ?? "")")
                    break
                case .unknown:
                    break
                @unknown default:
                    fatalError()
                }
            }
        )

        currentItem = item
    }

    /// 再生
    func play() {
        if (currentItem == nil) {
            return
        }

        avPlayer.play()
        displayLink.isPaused = false;
    }

    /// 一時停止
    func pause() {
        if (currentItem == nil) {
            return
        }

        avPlayer.pause()
        displayLink.isPaused = true;
    }

    // MARK:- CADisplayLink Events

    /// `CADisplayLink`よりリフレッシュレートに合わせて定期呼び出しされる処理
    @objc private func onDisplayLinkUpdate(_ displayLink: CADisplayLink) {
        // NOTE: ここでやっていることとしては、常にFlutterに対してテクスチャの更新命令を呼び出し続けているだけ
        textureRegistry.textureFrameAvailable(_textureId)
    }
}

// `textureRegistry.register`で登録するのに必要なprotocol
extension VideoPlayer: FlutterTexture {

    // `textureRegistry.textureFrameAvailable`が呼び出されたらこちらが発火される
    // → 戻り値で返したCVPixelBufferが実際にTextureWidget上に表示される
    public func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {

        // 現在のタイミングからPixelBufferを取得
        let outputItemTime = playerItemVideoOutput.itemTime(forHostTime: CACurrentMediaTime())
        guard playerItemVideoOutput.hasNewPixelBuffer(forItemTime: outputItemTime),
              let buffer = playerItemVideoOutput.copyPixelBuffer(forItemTime: outputItemTime, itemTimeForDisplay: nil) else {
            return nil
        }

        // ここで返したPixelBufferが実際にTextureWidget上に表示される
        return Unmanaged<CVPixelBuffer>.passRetained(buffer)
    }
}
