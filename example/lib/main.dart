import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_incall_manager/flutter_incall_manager.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  IncallManager incallManager = new IncallManager();

  @override
  initState() {
    super.initState();
  }

  void showResult(title, result) {
    print('$title => $result.');
  }

  List<Widget> buildTestButtons() {
    List<Map<String, dynamic>> items = [
      {
        'InCallManager.start(audio)': () {
          incallManager.start(
              media: MediaType.AUDIO, auto: false, ringback: '_DEFAULT_');
        }
      },
      {
        'InCallManager.start(video)': () {
          incallManager.start(
              media: MediaType.VIDEO, auto: false, ringback: '_DEFAULT_');
        }
      },
      {
        'InCallManager.stop': () {
          incallManager.stop();
        }
      },
      {
        'enableProximitySensor(true)': () {
          incallManager.enableProximitySensor(true);
        }
      },
      {
        'enableProximitySensor(false)': () {
          incallManager.enableProximitySensor(false);
        }
      },
      {
        'checkRecordPermission': () async {
          showResult('checkRecordPermission',
              await incallManager.checkRecordPermission());
        }
      },
      {
        'checkCameraPermission': () async {
          showResult('checkCameraPermission',
              await incallManager.checkCameraPermission());
        }
      },
      {
        'requestRecordPermission': () {
          incallManager.requestRecordPermission();
        }
      },
      {
        'requestCameraPermission': () {
          incallManager.requestCameraPermission();
        }
      },
      {
        'setKeepScreenOn(true)': () {
          incallManager.setKeepScreenOn(true);
        }
      },
      {
        'setKeepScreenOn(false)': () {
          incallManager.setKeepScreenOn(false);
        }
      },
      {
        'setSpeakerphoneOn(true)': () {
          incallManager.setSpeakerphoneOn(true);
        }
      },
      {
        'setSpeakerphoneOn(false)': () {
          incallManager.setSpeakerphoneOn(false);
        }
      },
      {
        'startRingback': () {
          incallManager.startRingback();
        }
      },
      {
        'stopRingback': () {
          incallManager.stopRingback();
        }
      },
      {
        'startRingtone(30)': () {
          incallManager.startRingtone(RingtoneUriType.DEFAULT, 'default', 30);
        }
      },
      {
        'stopRingtone': () {
          incallManager.stopRingtone();
        }
      },
    ];

    if (Platform.isAndroid) {
      items.addAll([
        {
          'turnScreenOn': () {
            incallManager.turnScreenOn();
          }
        },
        {
          'turnScreenOff': () {
            incallManager.turnScreenOff();
          }
        },
        {
          'setMicrophoneMute(true)': () {
            incallManager.setMicrophoneMute(true);
          }
        },
        {
          'setMicrophoneMute(false)': () {
            incallManager.setMicrophoneMute(false);
          }
        }
      ]);
    }

    return items
        .map((item) => RaisedButton(
              onPressed: () async {
                print('${item.keys.first}');
                await item.values.first();
              },
              child: new Text(item.keys.first),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter InCallManager example'),
        ),
        body: new SingleChildScrollView(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: buildTestButtons(),
          ),
        ),
      ),
    );
  }
}
