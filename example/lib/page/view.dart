import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sample_video_player/sample_video_player.dart';
import 'package:sample_video_player_example/page/view_model.dart';

/// 実装サンプル
class ExampleView extends StatefulWidget {
  ExampleView({Key? key}) : super(key: key);

  final _viewModel = ExampleViewModel();

  @override
  State<StatefulWidget> createState() => _ExampleState();
}

class _ExampleState extends State<ExampleView> {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => widget._viewModel,
        child: _ScaffoldWidget(),
      );
}

class _ScaffoldWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExampleViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: Column(
        children: <Widget>[
          // プレイヤーの追加・削除を行うメニュー的なの
          const Padding(padding: EdgeInsets.only(top: 32)),
          _MenuWidget(),

          // プレイヤー一覧
          // ※ざっくりと機能検証出来れば良いレベルなので雑に並べている
          const Padding(padding: EdgeInsets.only(top: 32)),
          for (int i = 0; i < viewModel.createdPlayers.length; ++i)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(padding: EdgeInsets.only(top: 8)),
                _VideoPlayerWidget(index: i),
              ],
            )
        ],
      ),
    );
  }
}

class _MenuWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ExampleViewModel>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // プレイヤーの追加
        IconButton(
          onPressed: () async {
            await viewModel.addPlayer();
          },
          icon: const Icon(Icons.add),
        ),

        // プレイヤーの削除
        IconButton(
          onPressed: () async {
            await viewModel.removePlayer();
          },
          icon: const Icon(Icons.remove),
        ),

        const Padding(padding: EdgeInsets.only(left: 16)),
        const Text(
          'プレイヤーの追加・削除',
        ),
      ],
    );
  }
}

// 動画プレイヤー
class _VideoPlayerWidget extends StatelessWidget {
  const _VideoPlayerWidget({
    required this.index,
    Key? key,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ExampleViewModel>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // VideoPlayerの表示
        _buildVideoPlayerWidget(context),

        // プレイヤー操作UI
        const Padding(padding: EdgeInsets.only(top: 8)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 動画の再生
            ElevatedButton(
              onPressed: () async {
                final player = viewModel.createdPlayers[index];
                await player.play();
              },
              child: const Text('再生'),
            ),

            // 動画の停止
            const Padding(padding: EdgeInsets.only(left: 16)),
            ElevatedButton(
              onPressed: () async {
                final player = viewModel.createdPlayers[index];
                await player.pause();
              },
              child: const Text('停止'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoPlayerWidget(BuildContext context) {
    final viewModel = context.watch<ExampleViewModel>();
    final textureId = viewModel.createdPlayers[index].textureId;

    // [16:9]のサイズで表示
    return SizedBox(
      width: 320 * 0.8,
      height: 180 * 0.8,
      // NOTE: textureIdが未登録状態の場合には黒塗りにしておく
      child: textureId != uninitializedTextureId
          ? Texture(textureId: textureId)
          : Container(color: Colors.black),
    );
  }
}
