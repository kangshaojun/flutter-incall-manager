import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incall/incall.dart';
import 'package:incall/incall_manager.dart';


void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  IncallManager incall = new IncallManager();


  @override
  initState() {
    super.initState();

    incall.checkRecordPermission();
    incall.requestRecordPermission();
    incall.start({'media':'audio', 'auto': true, 'ringback': ''});

  }



  testPlugin() async {

    //incall.startRingtone('DEFAULT',30);

    //Incall.setKeepScreenOn(true);

    //Incall.turnScreenOff();

    //incall.startRingback();

    //Incall.turnScreenOn();

//    String re1 = await incall.checkCameraPermission();
//
//    print('checkCameraPermission:success:' +  re1.toString());
//
//    String  re2 = await incall.requestCameraPermission();
//
//    print('requestCameraPermission:' +  re2.toString());
//
//    String re3 = await incall.checkCameraPermission();
//
//    print('checkCameraPermission:' +  re3.toString());

  }

  bool speakerOn = false;

  turnScreenOn() async {

   // incall.stopRingtone();

    //Incall.setKeepScreenOn(true);

    //Incall.turnScreenOn();



//    Incall.setMicrophoneMute(speakerOn);
//
//    speakerOn = !speakerOn;

    //incall.stopRingback();
    //Incall.turnScreenOff();


    //startTimeout(5000);

    //incall.setSpeakerphoneOn(true);

    //incall.getAudioUriJS('busytone','_DEFAULT_');

  }

  startTimeout([int milliseconds]) {

    const TIMEOUT = const Duration(seconds: 3);
    const ms = const Duration(milliseconds: 1);

    var duration = milliseconds == null ? TIMEOUT : ms * milliseconds;
    return new Timer(duration, handleTimeout);
  }



  void handleTimeout() {  // callback function
    //Incall.turnScreenOn();
    print('turnScreenOn:xxxx');
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(

          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new RaisedButton(
                  onPressed: (){
                    incall.turnScreenOn();
                  },
                  child: new Text('turnScreenOn'),
              ),
              new RaisedButton(
                onPressed: (){
                  incall.turnScreenOff();
                },
                child: new Text('turnScreenOff'),
              ),
              new RaisedButton(
                onPressed: (){
                  incall.setKeepScreenOn(true);
                },
                child: new Text('setKeepScreenOn.true'),
              ),
              new RaisedButton(
                onPressed: (){
                  incall.setKeepScreenOn(false);
                },
                child: new Text('setKeepScreenOn.false'),
              ),
              new RaisedButton(
                onPressed: (){
                  incall.setSpeakerphoneOn(true);
                },
                child: new Text('setSpeakerphoneOn.true'),
              ),
              new RaisedButton(
                onPressed: (){
                  incall.setSpeakerphoneOn(false);
                },
                child: new Text('setSpeakerphoneOn.false'),
              ),
              new RaisedButton(
                onPressed: (){
                  incall.startRingtone('DEFAULT','default',30);
                },
                child: new Text('startRingtone.30'),
              ),
              new RaisedButton(
                onPressed: (){
                  incall.stopRingtone();
                },
                child: new Text('stopRingtone'),
              ),
              new RaisedButton(
                onPressed: (){
                  incall.startRingback();
                },
                child: new Text('startRingback'),
              ),
              new RaisedButton(
                onPressed: (){
                  incall.stopRingback();
                },
                child: new Text('stopRingback'),
              ),
              new RaisedButton(
                onPressed: (){
                  //incall.getAudioUriJS();
                },
                child: new Text('getAudioUriJS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
