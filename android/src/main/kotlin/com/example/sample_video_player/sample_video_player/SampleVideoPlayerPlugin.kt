package com.example.sample_video_player.sample_video_player

import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.view.TextureRegistry

class SampleVideoPlayerPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context

    // FlutterPluginより取得可能なテクスチャの管理クラス
    private lateinit var textureRegistry: TextureRegistry

    // 登録したtextureId, 生成済みのプレイヤー
    private var createPlayers: MutableMap<Long, VideoPlayer> = mutableMapOf()


    // region FlutterPlugin Events

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        textureRegistry = flutterPluginBinding.textureRegistry

        // MethodChannelの登録
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "com.example.sample_video_player/method_channel")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)

        // 後片付け
        for (player in createPlayers.values) {
            player.dispose()
        }
        createPlayers.clear()
    }

    // endregion

    // region MethodCallHandler Events

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        if (call.method == "createPlayer") {
            onCreatePlayer(result)
            return
        }

        // 以降のメソッドは`textureId`が前提となるので事前に取得しておく

        // NTOE:
        // 「Flutterから渡されるint型」はKotlin(Java)上ではIntになるかLongになるかは決定的ではなく、
        // サイズに応じて変わる仕様があるっぽい？ので型チェックして変換を行う必要がある模様。
        // (公式のvideo_playerの実装がそうなっていた)
        // - https://github.com/flutter/plugins/blob/master/packages/video_player/video_player/android/src/main/java/io/flutter/plugins/videoplayer/Messages.java#L40
        // - https://docs.flutter.dev/development/platform-integration/platform-channels?tab=type-mappings-kotlin-tab#codec
        var textureId: Long? = null
        val id = call.argument<Any>("textureId")
        if (id != null) {
            textureId = if (id is Int) {
                id.toLong()
            } else {
                id as Long
            }
        }

        if (textureId == null) {
            result.error("bad args", null, null)
            return
        }

        when (call.method) {
            "disposePlayer" -> onDisposePlayer(textureId, result)
            "setUrl" -> onSetUrl(textureId, call, result)
            "play" -> onPlay(textureId, result)
            "pause" -> onPause(textureId, result)
            else -> result.notImplemented()
        }
    }

    // endregion

    // region Private Methods

    private fun onCreatePlayer(result: Result) {
        // テクスチャの登録
        val surfaceTextureEntry = textureRegistry.createSurfaceTexture()

        // Androidの場合は`SurfaceTextureEntry`クラスさえ渡しておけばプレイヤー側で完結可能
        // → iOSみたいに`textureRegistry`を丸ごと渡す必要はない
        val videoPlayer = VideoPlayer(applicationContext, surfaceTextureEntry)
        val textureId = surfaceTextureEntry.id()
        createPlayers[textureId] = videoPlayer
        result.success(textureId)
    }

    private fun onDisposePlayer(textureId: Long, result: Result) {
        createPlayers[textureId]?.let {
            it.dispose()
            createPlayers.remove(textureId)
        }

        result.success(null)
    }

    private fun onSetUrl(textureId: Long, call: MethodCall, result: Result) {
        createPlayers[textureId]?.let {
            val hlsUrl = call.argument<String>("hlsUrl") ?: run {
                result.error("bad args", null, null)
                return
            }

            it.setUrl(hlsUrl)
        }

        result.success(null)
    }

    private fun onPlay(textureId: Long, result: Result) {
        createPlayers[textureId]?.play()
        result.success(null)
    }

    private fun onPause(textureId: Long, result: Result) {
        createPlayers[textureId]?.pause()
        result.success(null)
    }

    // endregion
}
