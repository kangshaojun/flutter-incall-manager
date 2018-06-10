import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'incall.dart';

class IncallManager {
  MethodChannel _channel = Incall.methodChannel();
  StreamSubscription<dynamic> _eventSubscription;

  IncallManager() {
    //initEvent();
  }

  //事件监听处理
  initEvent() {
    _eventSubscription = _eventChannelFor()
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  //启动InCallManager
  Future<void> start(setup) async {

    //setup = (setup === undefined) ? {} : setup;
    bool auto = (setup['auto'] == false) ? false : true;
    String media = (setup['media'] == 'video') ? 'video' : 'audio';
    String ringback = setup['ringback'];

    try {
      await _channel.invokeMethod('start',<String,dynamic>{'media':media,'auto':auto,'ringback':ringback});
    } on PlatformException catch (e) {
      throw 'Unable to start: ${e.message}';
    }
  }

  //停止InCallManager
  Future<void> stop(setup) async {

    String busytone = setup['busytone'];
    try {
      await _channel.invokeMethod('stop',<String,dynamic>{'busytone':busytone});
    } on PlatformException catch (e) {
      throw 'Unable to stop: ${e.message}';
    }
  }

  Future<void> setKeepScreenOn(bool enable) async {
    try {
      await _channel
          .invokeMethod('setKeepScreenOn', <String, dynamic>{'enable': enable});
    } on PlatformException catch (e) {
      throw 'Unable to setKeepScreenOn: ${e.message}';
    }
  }

  Future<void> setSpeakerphoneOn(enable) async {
    try {
      await _channel.invokeMethod(
          'setSpeakerphoneOn', <String, dynamic>{'enable': enable});
    } on PlatformException catch (e) {
      throw 'Unable to setSpeakerphoneOn: ${e.message}';
    }
  }

  /*
   * flag: Int
   * 0: use default action
   * 1: force speaker on
   * -1: force speaker off
   */
  Future<void> setForceSpeakerphoneOn(flag) async {
    try {
      await _channel.invokeMethod(
          'setForceSpeakerphoneOn', <String, dynamic>{'flag': flag});
    } on PlatformException catch (e) {
      throw 'Unable to setForceSpeakerphoneOn: ${e.message}';
    }
  }

  Future<void> setMicrophoneMute(enable) async {
    try {
      await _channel.invokeMethod(
          'setMicrophoneMute', <String, dynamic>{'enable': enable});
    } on PlatformException catch (e) {
      throw 'Unable to setMicrophoneMute: ${e.message}';
    }
  }

  Future<void> turnScreenOff() async {
    try {
      await _channel.invokeMethod('turnScreenOff');
    } on PlatformException catch (e) {
      throw 'Unable to turnScreenOff: ${e.message}';
    }
  }

  Future<void> turnScreenOn() async {
    try {
      await _channel.invokeMethod('turnScreenOn');
    } on PlatformException catch (e) {
      throw 'Unable to turnScreenOn: ${e.message}';
    }
  }

  /*
  *获取声音文件路径
  */
  Future<void> getAudioUriJS(audioType,fileType) async {
    try {
      final Map<String,String> response = await _channel.invokeMethod('getAudioUriJS',<String, dynamic>{'audioType': audioType,'fileType':fileType});
      String uri = response['uri'];
      print('getAudioUriJS:uri:$uri');
    } on PlatformException catch (e) {
      throw 'Unable to getAudioUriJS: ${e.message}';
    }
  }

  /*
  ios_category:'ios value playback or default
  seconds:android only
  */
  Future<void> startRingtone(ringtoneUriType,ios_category,seconds) async {

    try {

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _channel.invokeMethod('startRingtone',<String, dynamic>{'ringtoneUriType': ringtoneUriType,'ios_category':ios_category});
      } else {

        await _channel.invokeMethod('startRingtone',<String, dynamic>{'ringtoneUriType': ringtoneUriType,'seconds':seconds});

      }


    } on PlatformException catch (e) {
      throw 'Unable to startRingtone: ${e.message}';
    }
  }

  Future<void> stopRingtone() async {
    try {
      await _channel.invokeMethod('stopRingtone');
    } on PlatformException catch (e) {
      throw 'Unable to stopRingtone: ${e.message}';
    }
  }

  Future<void> startRingback() async {
    try {
      await _channel.invokeMethod('startRingback');
    } on PlatformException catch (e) {
      throw 'Unable to startRingback: ${e.message}';
    }
  }

  Future<void> stopRingback() async {
    try {
      await _channel.invokeMethod('stopRingback');
    } on PlatformException catch (e) {
      throw 'Unable to stopRingback: ${e.message}';
    }
  }

  /*检测录制权限*/
  Future<String> checkRecordPermission() async {
    String re = "unknow";
    try {
      String response = await _channel.invokeMethod('checkRecordPermission');
      re = response;
      print("incall_manager.dart:checkRecordPermission:" + response);
    } on PlatformException catch (e) {
      throw 'checkRecordPermission: ${e.message}';
    }
    return re;
  }

  /*请求获取录制权限*/
  Future<String> requestRecordPermission() async {
    String re = "unknow";
    try {
      String response = await _channel.invokeMethod('requestRecordPermission');
      re = response;
    } on PlatformException catch (e) {
      throw 'requestRecordPermission: ${e.message}';
    }
    return re;
  }

  /*检测摄像头权限*/
  Future<String> checkCameraPermission() async {
    String re = "unknow";
    try {
      String response = await _channel.invokeMethod('checkCameraPermission');
      re = response;
    } on PlatformException catch (e) {
      throw 'checkCameraPermission: ${e.message}';
    }
    return re;
  }

  /*请求获取摄像权限*/
  Future<String> requestCameraPermission() async {
    String re = "unknow";
    try {
      String response = await _channel.invokeMethod('requestCameraPermission');
      re = response;
    } on PlatformException catch (e) {
      throw 'requestCameraPermission: ${e.message}';
    }
    return re;
  }

  EventChannel _eventChannelFor() {
    return new EventChannel('cloudwebrtc.com/incall.manager.event');
  }

  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;

    switch (map['event']) {
      case 'demoEvent':
        String id = map['id'];
        String value = map['value'];
        print("事件监听数据$id $value");
        break;
      case 'WiredHeadset'://有线耳机是否插入
        bool isPlugged = map['isPlugged'];
        bool hasMic = map['hasMic'];
        String deviceName = map['deviceName'];
        print(
            "WiredHeadset:isPlugged:$isPlugged hasMic:$hasMic deviceName:$deviceName");
        break;
      case 'NoisyAudio'://有线耳机是否拔掉
        String status = map['status'];
        print("NoisyAudio:status:$status");
        break;
      case 'MediaButton':
        String eventText = map['eventText'];
        int eventCode = map['eventCode'];
        break;
      case 'Proximity':
        bool isNear = map['isNear'];
        break;
      case 'onAudioFocusChange':
        String eventText = map['eventText'];
        bool eventCode = map['eventCode'];
        break;
      case 'onAudioDeviceChanged':
        String availableAudioDeviceList = map['availableAudioDeviceList'];
        String selectedAudioDevice = map['selectedAudioDevice'];
        break;
    }
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }
}
