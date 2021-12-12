
import 'dart:async';

import 'package:flutter/services.dart';

class SampleVideoPlayer {
  static const MethodChannel _channel = MethodChannel('sample_video_player');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
