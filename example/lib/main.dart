import 'package:flutter/material.dart';
import 'package:sample_video_player_example/page/view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => ExampleView(),
      },
    );
  }
}
