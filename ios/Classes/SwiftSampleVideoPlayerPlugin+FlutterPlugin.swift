import Foundation

extension SwiftSampleVideoPlayerPlugin: FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        // MethodChannelの登録
        let instance = SwiftSampleVideoPlayerPlugin(with: registrar)
        let channel = FlutterMethodChannel(
            name: "com.example.sample_video_player/method_channel",
            binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)

    }

    // MARK:- Method Channel

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        if (call.method == "createPlayer") {
            onCreatePlayer(result)
            return
        }

        // 以降のメソッドは`textureId`が前提となるので事前に取得しておく
        guard let args = call.arguments as? Dictionary<String, Any>,
              let textureId = args["textureId"] as? Int64 else {
            result(FlutterError.init(code: "bad args", message: nil, details: nil))
            return
        }

        switch (call.method) {
        case "disposePlayer":
            onDisposePlayer(textureId, result)
            break
        case "setUrl":
            onSetUrl(textureId, args, result)
            break
        case "play":
            onPlay(textureId, result)
            break
        case "pause":
            onPause(textureId, result)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }

    private func onCreatePlayer(_ result: @escaping FlutterResult) {
        let textureId = createPlayer()
        result(textureId)
    }

    private func onDisposePlayer(_ textureId: Int64, _ result: @escaping FlutterResult) {
        disposePlayer(with: textureId)
        result(nil)
    }

    private func onSetUrl(_ textureId: Int64, _ args: Dictionary<String, Any>, _ result: @escaping FlutterResult) {
        guard let hlsUrl = args["hlsUrl"] as? String else {
            result(FlutterError.init(code: "bad args", message: nil, details: nil))
            return
        }

        setUrl(with: textureId, hlsUrl: hlsUrl)
        result(nil)
    }

    private func onPlay(_ textureId: Int64, _ result: @escaping FlutterResult) {
        play(with: textureId)
        result(nil)
    }

    private func onPause(_ textureId: Int64, _ result: @escaping FlutterResult) {
        pause(with: textureId)
        result(nil)
    }
}
