package com.example.sample_video_player.sample_video_player

import android.content.Context
import android.view.Surface
import com.google.android.exoplayer2.C
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.audio.AudioAttributes
import com.google.android.exoplayer2.source.hls.HlsMediaSource
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource
import io.flutter.view.TextureRegistry

/**
 * 動画プレイヤー
 *
 * ExoPlayerをバックエンドに実装していく。
 */
class VideoPlayer(
    applicationContext: Context,
    private val surfaceTextureEntry: TextureRegistry.SurfaceTextureEntry,
) {
    private val exoPlayer: SimpleExoPlayer
    private val dataSourceFactory: DataSource.Factory
    private val surface: Surface

    init {
        // video_playerの実装を参考に初期化
        val player = SimpleExoPlayer.Builder(applicationContext).build()
        val factory = DefaultHttpDataSource.Factory()
            .setUserAgent("ExoPlayer")
            .setAllowCrossProtocolRedirects(true)

        // ExoPlayerに対し、テクスチャの紐付けを行う
        // NOTE: Androidの場合は簡単でPlayerにSurfaceを渡すだけで内部的によしなに更新してくれる
        val createSurface = Surface(surfaceTextureEntry.surfaceTexture())
        player.setVideoSurface(createSurface)
        player.setAudioAttributes(
            AudioAttributes.Builder().setContentType(C.CONTENT_TYPE_MOVIE).build(),
            false)

        exoPlayer = player
        dataSourceFactory = factory
        surface = createSurface
    }

    /**
     * プレイヤーの破棄
     */
    fun dispose() {
        // テクスチャの登録解除
        surfaceTextureEntry.release()

        surface.release()
        exoPlayer.release()
    }

    /**
     * 再生する動画URLの指定
     *
     * @param hlsUrl hls形式の動画URL
     */
    fun setUrl(hlsUrl: String) {
        val hlsMediaSource = HlsMediaSource.Factory(dataSourceFactory)
            .createMediaSource(MediaItem.fromUri(hlsUrl))

        exoPlayer.setMediaSource(hlsMediaSource)
        exoPlayer.prepare()
    }

    /**
     * 再生
     */
    fun play() {
        exoPlayer.playWhenReady = true
    }

    /**
     * 一時停止
     */
    fun pause() {
        exoPlayer.playWhenReady = false
    }
}
