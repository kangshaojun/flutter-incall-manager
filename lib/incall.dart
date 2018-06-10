import 'package:flutter/services.dart';

class Incall {

  static const MethodChannel _channel = const MethodChannel('cloudwebrtc.com/incall.manager');
  static MethodChannel methodChannel() => _channel;

}
