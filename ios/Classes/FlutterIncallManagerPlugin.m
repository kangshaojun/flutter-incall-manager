#import "FlutterIncallManagerPlugin.h"

@implementation FlutterIncallManagerPlugin{
    
    UIDevice *_currentDevice;
    
    AVAudioSession *_audioSession;
    AVAudioPlayer *_ringtone;
    AVAudioPlayer *_ringback;
    AVAudioPlayer *_busytone;
    
    NSURL *_defaultRingtoneUri;
    NSURL *_defaultRingbackUri;
    NSURL *_defaultBusytoneUri;
    NSURL *_bundleRingtoneUri;
    NSURL *_bundleRingbackUri;
    NSURL *_bundleBusytoneUri;
    
    //BOOL isProximitySupported;
    BOOL _proximityIsNear;
    
    // --- tags to indicating which observer has added
    BOOL _isProximityRegistered;
    BOOL _isAudioSessionInterruptionRegistered;
    BOOL _isAudioSessionRouteChangeRegistered;
    BOOL _isAudioSessionMediaServicesWereLostRegistered;
    BOOL _isAudioSessionMediaServicesWereResetRegistered;
    BOOL _isAudioSessionSilenceSecondaryAudioHintRegistered;
    
    // -- notification observers
    id _proximityObserver;
    id _audioSessionInterruptionObserver;
    id _audioSessionRouteChangeObserver;
    id _audioSessionMediaServicesWereLostObserver;
    id _audioSessionMediaServicesWereResetObserver;
    id _audioSessionSilenceSecondaryAudioHintObserver;
    
    NSString *_incallAudioMode;
    NSString *_incallAudioCategory;
    NSString *_origAudioCategory;
    NSString *_origAudioMode;
    BOOL _audioSessionInitialized;
    int _forceSpeakerOn;
    NSString *_recordPermission;
    NSString *_cameraPermission;
    NSString *_media;
    
}

//
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"cloudwebrtc.com/incall.manager"
                                     binaryMessenger:[registrar messenger]];
    FlutterIncallManagerPlugin* instance = [[FlutterIncallManagerPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSDictionary* argsMap = call.arguments;
    
    if ([@"start" isEqualToString:call.method]) {
        NSString* media = argsMap[@"media"];
        BOOL isAuto = [argsMap[@"auto"] boolValue];
        NSString* ringback = argsMap[@"ringback"];
        [self start:media auto:isAuto ringbackUriType:ringback];
        //result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
        result(nil);
    }
    else if([@"stop" isEqualToString:call.method]){
        NSString* busytone = argsMap[@"busytone"];
        [self stop:busytone];
        result(nil);
    }
    else if([@"setKeepScreenOn" isEqualToString:call.method]){
        BOOL enable = [argsMap[@"enable"] boolValue];
        [self setKeepScreenOn:enable];
        result(nil);
    }
    else if([@"setSpeakerphoneOn" isEqualToString:call.method]){
        BOOL enable = [argsMap[@"enable"] boolValue];
        [self setSpeakerphoneOn:enable];
        result(nil);
    }
    else if([@"setForceSpeakerphoneOn" isEqualToString:call.method]){
        BOOL flag = [argsMap[@"flag"] boolValue];
        [self setForceSpeakerphoneOn:flag];
        result(nil);
    }
    else if([@"setMicrophoneMute" isEqualToString:call.method]){
        BOOL enable = [argsMap[@"flag"] boolValue];
        [self setMicrophoneMute:enable];
        result(nil);
    }
    else if([@"turnScreenOn" isEqualToString:call.method]){
        [self turnScreenOn];
        result(nil);
    }
    else if([@"turnScreenOff" isEqualToString:call.method]){
        [self turnScreenOff];
        result(nil);
    }
    else if([@"startRingtone" isEqualToString:call.method]){
        NSString* ringtoneUriType = argsMap[@"ringtoneUriType"];
        NSString* ios_category = argsMap[@"ios_category"];
        [self startRingtone:ringtoneUriType ringtoneCategory:ios_category];
        result(nil);
    }
    else if([@"stopRingtone" isEqualToString:call.method]){
        [self stopRingtone];
        result(nil);
    }
    else if([@"startRingback" isEqualToString:call.method]){
        [self startRingback:@"_BUNDLE_"];
        result(nil);
    }
    else if([@"stopRingback" isEqualToString:call.method]){
        [self stopRingback];
        result(nil);
    }
    else if([@"getAudioUriJS" isEqualToString:call.method]){
        NSString* audioType = argsMap[@"audioType"];
        NSString* fileType = argsMap[@"fileType"];
        [self getAudioUriJS:audioType fileType:fileType flutterResult:result];
    }
    else if([@"checkRecordPermission" isEqualToString:call.method]){
        [self checkRecordPermission:result];
    }
    else if([@"requestRecordPermission" isEqualToString:call.method]){
        [self requestRecordPermission:result];
    }
    else if([@"checkCameraPermission" isEqualToString:call.method]){
        [self checkCameraPermission:result];
    }
    else if([@"requestCameraPermission" isEqualToString:call.method]){
        [self requestCameraPermission:result];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (instancetype)init
{
    if (self = [super init]) {
        _currentDevice = [UIDevice currentDevice];
        _audioSession = [AVAudioSession sharedInstance];
        _ringtone = nil;
        _ringback = nil;
        _busytone = nil;
        
        _defaultRingtoneUri = nil;
        _defaultRingbackUri = nil;
        _defaultBusytoneUri = nil;
        _bundleRingtoneUri = nil;
        _bundleRingbackUri = nil;
        _bundleBusytoneUri = nil;
        
        _proximityIsNear = NO;
        
        _isProximityRegistered = NO;
        _isAudioSessionInterruptionRegistered = NO;
        _isAudioSessionRouteChangeRegistered = NO;
        _isAudioSessionMediaServicesWereLostRegistered = NO;
        _isAudioSessionMediaServicesWereResetRegistered = NO;
        _isAudioSessionSilenceSecondaryAudioHintRegistered = NO;
        
        _proximityObserver = nil;
        _audioSessionInterruptionObserver = nil;
        _audioSessionRouteChangeObserver = nil;
        _audioSessionMediaServicesWereLostObserver = nil;
        _audioSessionMediaServicesWereResetObserver = nil;
        _audioSessionSilenceSecondaryAudioHintObserver = nil;
        
        _incallAudioMode = AVAudioSessionModeVoiceChat;
        _incallAudioCategory = AVAudioSessionCategoryPlayAndRecord;
        _origAudioCategory = nil;
        _origAudioMode = nil;
        _audioSessionInitialized = NO;
        _forceSpeakerOn = 0;
        _recordPermission = nil;
        _cameraPermission = nil;
        _media = @"audio";
        
        NSLog(@"FlutterInCallManager.init(): initialized");
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stop:@""];
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"Proximity",
             @"WiredHeadset"];
}

- (void) start:(NSString *)mediaType
          auto:(BOOL)_auto
ringbackUriType:(NSString *)ringbackUriType
{
    if (_audioSessionInitialized) {
        return;
    }
    if (![_recordPermission isEqualToString:@"granted"]) {
        NSLog(@"FlutterInCallManager.start(): recordPermission should be granted. state: %@", _recordPermission);
        return;
    }
    _media = mediaType;
    
    // --- auto is always true on ios
    if ([_media isEqualToString:@"video"]) {
        _incallAudioMode = AVAudioSessionModeVideoChat;
    } else {
        _incallAudioMode = AVAudioSessionModeVoiceChat;
    }
    NSLog(@"FlutterInCallManager.start() start InCallManager. media=%@, type=%@, mode=%@", _media, _media, _incallAudioMode);
    [self storeOriginalAudioSetup];
    _forceSpeakerOn = 0;
    [self startAudioSessionNotification];
    [self audioSessionSetCategory:_incallAudioCategory
                          options:0
                       callerMemo:NSStringFromSelector(_cmd)];
    [self audioSessionSetMode:_incallAudioMode
                   callerMemo:NSStringFromSelector(_cmd)];
    [self audioSessionSetActive:YES
                        options:0
                     callerMemo:NSStringFromSelector(_cmd)];
    
    if (ringbackUriType.length > 0) {
        NSLog(@"FlutterInCallManager.start() play ringback first. type=%@", ringbackUriType);
        [self startRingback:ringbackUriType];
    }
    
    if ([_media isEqualToString:@"audio"]) {
        [self startProximitySensor];
    }
    [self setKeepScreenOn:YES];
    _audioSessionInitialized = YES;
    //self.debugAudioSession()
}

- (void) stop:(NSString *)busytoneUriType
{
    if (!_audioSessionInitialized) {
        return;
    }
    
    [self stopRingback];
    
    if (busytoneUriType.length > 0 && [self startBusytone:busytoneUriType]) {
        // play busytone first, and call this func again when finish
        NSLog(@"FlutterInCallManager.stop(): play busytone before stop");
        return;
    } else {
        NSLog(@"FlutterInCallManager.stop(): stop InCallManager");
        [self restoreOriginalAudioSetup];
        [self stopBusytone];
        [self stopProximitySensor];
        [self audioSessionSetActive:NO
                            options:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                         callerMemo:NSStringFromSelector(_cmd)];
        [self setKeepScreenOn:NO];
        [self stopAudioSessionNotification];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        _forceSpeakerOn = 0;
        _audioSessionInitialized = NO;
    }
}

- (void) turnScreenOn
{
    NSLog(@"FlutterInCallManager.turnScreenOn(): ios doesn't support turnScreenOn()");
}

- (void) turnScreenOff
{
    NSLog(@"FlutterInCallManager.turnScreenOff(): ios doesn't support turnScreenOff()");
}

-setFlashOn:(BOOL)enable
 brightness:(nonnull NSNumber *)brightness
{
    if ([AVCaptureDevice class]) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device.hasTorch && device.position == AVCaptureDevicePositionBack) {
            @try {
                [device lockForConfiguration:nil];
                
                if (enable) {
                    [device setTorchMode:AVCaptureTorchModeOn];
                } else {
                    [device setTorchMode:AVCaptureTorchModeOff];
                }
                
                [device unlockForConfiguration];
            } @catch (NSException *e) {}
        }
    }
}

- (void) setKeepScreenOn:(BOOL)enable
{
    NSLog(@"FlutterInCallManager.setKeepScreenOn(): enable: %@", enable ? @"YES" : @"NO");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:enable];
    });
}

- (void) setSpeakerphoneOn:(BOOL)enable
{
    NSLog(@"FlutterInCallManager.setSpeakerphoneOn(): ios doesn't support setSpeakerphoneOn()");
}

- (void) setForceSpeakerphoneOn:(int)flag
{
    _forceSpeakerOn = flag;
    NSLog(@"FlutterInCallManager.setForceSpeakerphoneOn(): flag: %d", flag);
    [self updateAudioRoute];
}

- (void) setMicrophoneMute:(BOOL)enable
{
    NSLog(@"FlutterInCallManager.setMicrophoneMute(): ios doesn't support setMicrophoneMute()");
}

- (void)startRingback:(NSString *)_ringbackUriType
{
    // you may rejected by apple when publish app if you use system sound instead of bundled sound.
    NSLog(@"FlutterInCallManager.startRingback(): type=%@", _ringbackUriType);
    
    @try {
        if (_ringback != nil) {
            if ([_ringback isPlaying]) {
                NSLog(@"FlutterInCallManager.startRingback(): is already playing");
                return;
            } else {
                [self stopRingback];
            }
        }
        // ios don't have embedded DTMF tone generator. use system dtmf sound files.
        NSString *ringbackUriType = [_ringbackUriType isEqualToString:@"_DTMF_"]
        ? @"_DEFAULT_"
        : _ringbackUriType;
        NSURL *ringbackUri = [self getRingbackUri:ringbackUriType];
        if (ringbackUri == nil) {
            NSLog(@"FlutterInCallManager.startRingback(): no available media");
            return;
        }
        //self.storeOriginalAudioSetup()
        _ringback = [[AVAudioPlayer alloc] initWithContentsOfURL:ringbackUri error:nil];
        _ringback.delegate = self;
        _ringback.numberOfLoops = -1; // you need to stop it explicitly
        [_ringback prepareToPlay];
        
        //self.audioSessionSetCategory(self.incallAudioCategory, [.DefaultToSpeaker, .AllowBluetooth], #function)
        [self audioSessionSetCategory:_incallAudioCategory
                              options:0
                           callerMemo:NSStringFromSelector(_cmd)];
        [self audioSessionSetMode:_incallAudioMode
                       callerMemo:NSStringFromSelector(_cmd)];
        [_ringback play];
    } @catch (NSException *e) {
        NSLog(@"FlutterInCallManager.startRingback(): caught error=%@", e.reason);
    }
}

- (void) stopRingback
{
    if (_ringback != nil) {
        NSLog(@"FlutterInCallManager.stopRingback()");
        [_ringback stop];
        _ringback = nil;
        // --- need to reset route based on config because WebRTC seems will switch audio mode automatically when call established.
        //[self updateAudioRoute];
    }
}

- (void) startRingtone:(NSString *)ringtoneUriType
      ringtoneCategory:(NSString *)ringtoneCategory
{
    // you may rejected by apple when publish app if you use system sound instead of bundled sound.
    NSLog(@"FlutterInCallManager.startRingtone(): type: %@", ringtoneUriType);
    @try {
        if (_ringtone != nil) {
            if ([_ringtone isPlaying]) {
                NSLog(@"FlutterInCallManager.startRingtone(): is already playing.");
                return;
            } else {
                [self stopRingtone];
            }
        }
        NSURL *ringtoneUri = [self getRingtoneUri:ringtoneUriType];
        if (ringtoneUri == nil) {
            NSLog(@"FlutterInCallManager.startRingtone(): no available media");
            return;
        }
        
        // --- ios has Ringer/Silent switch, so just play without check ringer volume.
        [self storeOriginalAudioSetup];
        _ringtone = [[AVAudioPlayer alloc] initWithContentsOfURL:ringtoneUri error:nil];
        _ringtone.delegate = self;
        _ringtone.numberOfLoops = -1; // you need to stop it explicitly
        [_ringtone prepareToPlay];
        
        // --- 1. if we use Playback, it can supports background playing (starting from foreground), but it would not obey Ring/Silent switch.
        // ---    make sure you have enabled 'audio' tag ( or 'voip' tag ) at XCode -> Capabilities -> BackgroundMode
        // --- 2. if we use SoloAmbient, it would obey Ring/Silent switch in the foreground, but does not support background playing,
        // ---    thus, then you should play ringtone again via local notification after back to home during a ring session.
        
        // we prefer 2. by default, since most of users doesn't want to interrupted by a ringtone if Silent mode is on.
        
        //self.audioSessionSetCategory(AVAudioSessionCategoryPlayback, [.DuckOthers], #function)
        if ([ringtoneCategory isEqualToString:@"playback"]) {
            [self audioSessionSetCategory:AVAudioSessionCategoryPlayback
                                  options:0
                               callerMemo:NSStringFromSelector(_cmd)];
        } else {
            [self audioSessionSetCategory:AVAudioSessionCategorySoloAmbient
                                  options:0
                               callerMemo:NSStringFromSelector(_cmd)];
        }
        [self audioSessionSetMode:AVAudioSessionModeDefault
                       callerMemo:NSStringFromSelector(_cmd)];
        //[self audioSessionSetActive:YES
        //                    options:nil
        //                 callerMemo:NSStringFromSelector(_cmd)];
        [_ringtone play];
    } @catch (NSException *e) {
        NSLog(@"FlutterInCallManager.startRingtone(): caught error = %@", e.reason);
    }
}

- (void) stopRingtone
{
    if (_ringtone != nil) {
        NSLog(@"FlutterInCallManager.stopRingtone()");
        [_ringtone stop];
        _ringtone = nil;
        [self restoreOriginalAudioSetup];
        [self audioSessionSetActive:NO
                            options:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                         callerMemo:NSStringFromSelector(_cmd)];
    }
}

- (void) _checkRecordPermission
{
    NSString *recordPermission = @"unsupported";
    switch ([_audioSession recordPermission]) {
        case AVAudioSessionRecordPermissionGranted:
            recordPermission = @"granted";
            break;
        case AVAudioSessionRecordPermissionDenied:
            recordPermission = @"denied";
            break;
        case AVAudioSessionRecordPermissionUndetermined:
            recordPermission = @"undetermined";
            break;
        default:
            recordPermission = @"unknow";
            break;
    }
    _recordPermission = recordPermission;
    NSLog(@"FlutterInCallManager._checkRecordPermission(): recordPermission=%@", _recordPermission);
}

- (void) checkRecordPermission:(FlutterResult)flutterResult
{
    [self _checkRecordPermission];
    if (_recordPermission != nil) {
        //resolve(_recordPermission);
        flutterResult(_recordPermission);
    } else {
        //reject(@"error_code", @"error message", RCTErrorWithMessage(@"checkRecordPermission is nil"));
        flutterResult(@"");
    }
}

- (void) requestRecordPermission:(FlutterResult)flutterResult
{
    NSLog(@"FlutterInCallManager.requestRecordPermission(): waiting for user confirmation...");
    [_audioSession requestRecordPermission:^(BOOL granted) {
        if (granted) {
            _recordPermission = @"granted";
        } else {
            _recordPermission = @"denied";
        }
        NSLog(@"FlutterInCallManager.requestRecordPermission(): %@", _recordPermission);
        //resolve(_recordPermission);
        flutterResult(_recordPermission);
    }];
}

- (NSString *)_checkMediaPermission:(NSString *)targetMediaType
{
    switch ([AVCaptureDevice authorizationStatusForMediaType:targetMediaType]) {
        case AVAuthorizationStatusAuthorized:
            return @"granted";
        case AVAuthorizationStatusDenied:
            return @"denied";
        case AVAuthorizationStatusNotDetermined:
            return @"undetermined";
        case AVAuthorizationStatusRestricted:
            return @"restricted";
        default:
            return @"unknow";
    }
}

- (void)_checkCameraPermission
{
    _cameraPermission = [self _checkMediaPermission:AVMediaTypeVideo];
    NSLog(@"FlutterInCallManager._checkCameraPermission(): using iOS7 api. cameraPermission=%@", _cameraPermission);
}

- (void) checkCameraPermission:(FlutterResult)flutterResult
{
    [self _checkCameraPermission];
    if (_cameraPermission != nil) {
        //resolve(_cameraPermission);
        flutterResult(_cameraPermission);
    } else {
        //reject(@"error_code", @"error message", RCTErrorWithMessage(@"checkCameraPermission is nil"));
        flutterResult(@"");
    }
}

- (void) requestCameraPermission:(FlutterResult)flutterResult
{
    NSLog(@"FlutterInCallManager.requestCameraPermission(): waiting for user confirmation...");
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
                                 if (granted) {
                                     _cameraPermission = @"granted";
                                 } else {
                                     _cameraPermission = @"denied";
                                 }
                                 NSLog(@"FlutterInCallManager.requestCameraPermission(): %@", _cameraPermission);
                                 //resolve(_cameraPermission);
                             }];
    flutterResult(_cameraPermission);
}

- (void) getAudioUriJS:(NSString *)audioType
              fileType:(NSString *)fileType
         flutterResult:(FlutterResult)flutterResult

{
    NSURL *result = nil;
    if ([audioType isEqualToString:@"ringback"]) {
        result = [self getRingbackUri:fileType];
    } else if ([audioType isEqualToString:@"busytone"]) {
        result = [self getBusytoneUri:fileType];
    } else if ([audioType isEqualToString:@"ringtone"]) {
        result = [self getRingtoneUri:fileType];
    }
    if (result != nil) {
        if (result.absoluteString.length > 0) {
            //resolve(result.absoluteString);
            flutterResult(@{@"uri": result});
            return;
        }
    }
    flutterResult(@{@"uri": @""});
    //reject(@"error_code", @"getAudioUriJS() failed", RCTErrorWithMessage(@"getAudioUriJS() failed"));
}

- (void) getIsWiredHeadsetPluggedIn
{
    BOOL wiredHeadsetPluggedIn = [self isWiredHeadsetPluggedIn];
    //    resolve(@[@{
    //                  @"isWiredHeadsetPluggedIn": wiredHeadsetPluggedIn ? @YES : @NO,
    //                  }]);
}

- (void)updateAudioRoute
{
    NSLog(@"FlutterInCallManager.updateAudioRoute(): [Enter] forceSpeakerOn flag=%d media=%@ category=%@ mode=%@", _forceSpeakerOn, _media, _audioSession.category, _audioSession.mode);
    //self.debugAudioSession()
    
    //AVAudioSessionPortOverride overrideAudioPort;
    int overrideAudioPort;
    NSString *overrideAudioPortString = @"";
    NSString *audioMode = @"";
    
    // --- WebRTC native code will change audio mode automatically when established.
    // --- It would have some race condition if we change audio mode with webrtc at the same time.
    // --- So we should not change audio mode as possible as we can. Only when default video call which wants to force speaker off.
    // --- audio: only override speaker on/off; video: should change category if needed and handle proximity sensor. ( because default proximity is off when video call )
    if (_forceSpeakerOn == 1) {
        // --- force ON, override speaker only, keep audio mode remain.
        overrideAudioPort = AVAudioSessionPortOverrideSpeaker;
        overrideAudioPortString = @".Speaker";
        if ([_media isEqualToString:@"video"]) {
            audioMode = AVAudioSessionModeVideoChat;
            [self stopProximitySensor];
        }
    } else if (_forceSpeakerOn == -1) {
        // --- force off
        overrideAudioPort = AVAudioSessionPortOverrideNone;
        overrideAudioPortString = @".None";
        if ([_media isEqualToString:@"video"]) {
            audioMode = AVAudioSessionModeVoiceChat;
            [self startProximitySensor];
        }
    } else { // use default behavior
        overrideAudioPort = AVAudioSessionPortOverrideNone;
        overrideAudioPortString = @".None";
        if ([_media isEqualToString:@"video"]) {
            audioMode = AVAudioSessionModeVideoChat;
            [self stopProximitySensor];
        }
    }
    
    BOOL isCurrentRouteToSpeaker;
    isCurrentRouteToSpeaker = [self checkAudioRoute:@[AVAudioSessionPortBuiltInSpeaker]
                                          routeType:@"output"];
    if ((overrideAudioPort == AVAudioSessionPortOverrideSpeaker && !isCurrentRouteToSpeaker)
        || (overrideAudioPort == AVAudioSessionPortOverrideNone && isCurrentRouteToSpeaker)) {
        @try {
            [_audioSession overrideOutputAudioPort:overrideAudioPort error:nil];
            NSLog(@"FlutterInCallManager.updateAudioRoute(): audioSession.overrideOutputAudioPort(%@) success", overrideAudioPortString);
        } @catch (NSException *e) {
            NSLog(@"FlutterInCallManager.updateAudioRoute(): audioSession.overrideOutputAudioPort(%@) fail: %@", overrideAudioPortString, e.reason);
        }
    } else {
        NSLog(@"FlutterInCallManager.updateAudioRoute(): did NOT overrideOutputAudioPort()");
    }
    
    if (audioMode.length > 0 && ![_audioSession.mode isEqualToString:audioMode]) {
        [self audioSessionSetMode:audioMode
                       callerMemo:NSStringFromSelector(_cmd)];
        NSLog(@"FlutterInCallManager.updateAudioRoute() audio mode has changed to %@", audioMode);
    } else {
        NSLog(@"FlutterInCallManager.updateAudioRoute() did NOT change audio mode");
    }
    //self.debugAudioSession()
}

- (BOOL)checkAudioRoute:(NSArray<NSString *> *)targetPortTypeArray
              routeType:(NSString *)routeType
{
    AVAudioSessionRouteDescription *currentRoute = _audioSession.currentRoute;
    
    if (currentRoute != nil) {
        NSArray<AVAudioSessionPortDescription *> *routes = [routeType isEqualToString:@"input"]
        ? currentRoute.inputs
        : currentRoute.outputs;
        for (AVAudioSessionPortDescription *portDescription in routes) {
            if ([targetPortTypeArray containsObject:portDescription.portType]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)startBusytone:(NSString *)_busytoneUriType
{
    // you may rejected by apple when publish app if you use system sound instead of bundled sound.
    NSLog(@"FlutterInCallManager.startBusytone(): type: %@", _busytoneUriType);
    @try {
        if (_busytone != nil) {
            if ([_busytone isPlaying]) {
                NSLog(@"FlutterInCallManager.startBusytone(): is already playing");
                return NO;
            } else {
                [self stopBusytone];
            }
        }
        
        // ios don't have embedded DTMF tone generator. use system dtmf sound files.
        NSString *busytoneUriType = [_busytoneUriType isEqualToString:@"_DTMF_"]
        ? @"_DEFAULT_"
        : _busytoneUriType;
        NSURL *busytoneUri = [self getBusytoneUri:busytoneUriType];
        if (busytoneUri == nil) {
            NSLog(@"FlutterInCallManager.startBusytone(): no available media");
            return NO;
        }
        //[self storeOriginalAudioSetup];
        _busytone = [[AVAudioPlayer alloc] initWithContentsOfURL:busytoneUri error:nil];
        _busytone.delegate = self;
        _busytone.numberOfLoops = 0; // it's part of start(), will stop at stop()
        [_busytone prepareToPlay];
        
        //self.audioSessionSetCategory(self.incallAudioCategory, [.DefaultToSpeaker, .AllowBluetooth], #function)
        [self audioSessionSetCategory:_incallAudioCategory
                              options:0
                           callerMemo:NSStringFromSelector(_cmd)];
        [self audioSessionSetMode:_incallAudioMode
                       callerMemo:NSStringFromSelector(_cmd)];
        [_busytone play];
    } @catch (NSException *e) {
        NSLog(@"FlutterInCallManager.startBusytone(): caught error = %@", e.reason);
        return NO;
    }
    return YES;
}

- (void)stopBusytone
{
    if (_busytone != nil) {
        NSLog(@"FlutterInCallManager.stopBusytone()");
        [_busytone stop];
        _busytone = nil;
    }
}

- (BOOL)isWiredHeadsetPluggedIn
{
    // --- only check for a audio device plugged into headset port instead bluetooth/usb/hdmi
    return [self checkAudioRoute:@[AVAudioSessionPortHeadphones]
                       routeType:@"output"]
    || [self checkAudioRoute:@[AVAudioSessionPortHeadsetMic]
                   routeType:@"input"];
}

- (void)audioSessionSetCategory:(NSString *)audioCategory
                        options:(AVAudioSessionCategoryOptions)options
                     callerMemo:(NSString *)callerMemo
{
    @try {
        if (options != 0) {
            [_audioSession setCategory:audioCategory
                           withOptions:options
                                 error:nil];
        } else {
            [_audioSession setCategory:audioCategory
                                 error:nil];
        }
        NSLog(@"FlutterInCallManager.%@: audioSession.setCategory: %@, withOptions: %lu success", callerMemo, audioCategory, (unsigned long)options);
    } @catch (NSException *e) {
        NSLog(@"FlutterInCallManager.%@: audioSession.setCategory: %@, withOptions: %lu fail: %@", callerMemo, audioCategory, (unsigned long)options, e.reason);
    }
}

- (void)audioSessionSetMode:(NSString *)audioMode
                 callerMemo:(NSString *)callerMemo
{
    @try {
        [_audioSession setMode:audioMode error:nil];
        NSLog(@"FlutterInCallManager.%@: audioSession.setMode(%@) success", callerMemo, audioMode);
    } @catch (NSException *e) {
        NSLog(@"FlutterInCallManager.%@: audioSession.setMode(%@) fail: %@", callerMemo, audioMode, e.reason);
    }
}

- (void)audioSessionSetActive:(BOOL)audioActive
                      options:(AVAudioSessionSetActiveOptions)options
                   callerMemo:(NSString *)callerMemo
{
    @try {
        if (options != 0) {
            [_audioSession setActive:audioActive
                         withOptions:options
                               error:nil];
        } else {
            [_audioSession setActive:audioActive
                               error:nil];
        }
        NSLog(@"FlutterInCallManager.%@: audioSession.setActive(%@), withOptions: %lu success", callerMemo, audioActive ? @"YES" : @"NO", (unsigned long)options);
    } @catch (NSException *e) {
        NSLog(@"FlutterInCallManager.%@: audioSession.setActive(%@), withOptions: %lu fail: %@", callerMemo, audioActive ? @"YES" : @"NO", (unsigned long)options, e.reason);
    }
}

- (void)storeOriginalAudioSetup
{
    NSLog(@"FlutterInCallManager.storeOriginalAudioSetup(): origAudioCategory=%@, origAudioMode=%@", _audioSession.category, _audioSession.mode);
    _origAudioCategory = _audioSession.category;
    _origAudioMode = _audioSession.mode;
}

- (void)restoreOriginalAudioSetup
{
    NSLog(@"FlutterInCallManager.restoreOriginalAudioSetup(): origAudioCategory=%@, origAudioMode=%@", _audioSession.category, _audioSession.mode);
    [self audioSessionSetCategory:_origAudioCategory
                          options:0
                       callerMemo:NSStringFromSelector(_cmd)];
    [self audioSessionSetMode:_origAudioMode
                   callerMemo:NSStringFromSelector(_cmd)];
}

- (void)startProximitySensor
{
    if (_isProximityRegistered) {
        return;
    }
    
    NSLog(@"FlutterInCallManager.startProximitySensor()");
    _currentDevice.proximityMonitoringEnabled = YES;
    
    // --- in case it didn't deallocate when ViewDidUnload
    [self stopObserve:_proximityObserver
                 name:UIDeviceProximityStateDidChangeNotification
               object:nil];
    
    _proximityObserver = [self startObserve:UIDeviceProximityStateDidChangeNotification
                                     object:_currentDevice
                                      queue: nil
                                      block:^(NSNotification *notification) {
                                          BOOL state = _currentDevice.proximityState;
                                          if (state != _proximityIsNear) {
                                              NSLog(@"FlutterInCallManager.UIDeviceProximityStateDidChangeNotification(): isNear: %@", state ? @"YES" : @"NO");
                                              _proximityIsNear = state;
                                              //                                              [self sendEventWithName:@"Proximity" body:@[@{@"isNear": state ? @YES : @NO}]];
                                          }
                                      }];
    
    _isProximityRegistered = YES;
}

- (void)stopProximitySensor
{
    if (!_isProximityRegistered) {
        return;
    }
    
    NSLog(@"FlutterInCallManager.stopProximitySensor()");
    _currentDevice.proximityMonitoringEnabled = NO;
    
    // --- remove all no matter what object
    [self stopObserve:_proximityObserver
                 name:UIDeviceProximityStateDidChangeNotification
               object:nil];
    
    _isProximityRegistered = NO;
}

- (void)startAudioSessionNotification
{
    NSLog(@"FlutterInCallManager.startAudioSessionNotification() starting...");
    [self startAudioSessionInterruptionNotification];
    [self startAudioSessionRouteChangeNotification];
    [self startAudioSessionMediaServicesWereLostNotification];
    [self startAudioSessionMediaServicesWereResetNotification];
    [self startAudioSessionSilenceSecondaryAudioHintNotification];
}

- (void)stopAudioSessionNotification
{
    NSLog(@"FlutterInCallManager.startAudioSessionNotification() stopping...");
    [self stopAudioSessionInterruptionNotification];
    [self stopAudioSessionRouteChangeNotification];
    [self stopAudioSessionMediaServicesWereLostNotification];
    [self stopAudioSessionMediaServicesWereResetNotification];
    [self stopAudioSessionSilenceSecondaryAudioHintNotification];
}

- (void)startAudioSessionInterruptionNotification
{
    if (_isAudioSessionInterruptionRegistered) {
        return;
    }
    NSLog(@"FlutterInCallManager.startAudioSessionInterruptionNotification()");
    
    // --- in case it didn't deallocate when ViewDidUnload
    [self stopObserve:_audioSessionInterruptionObserver
                 name:AVAudioSessionInterruptionNotification
               object:nil];
    
    _audioSessionInterruptionObserver = [self startObserve:AVAudioSessionInterruptionNotification
                                                    object:nil
                                                     queue:nil
                                                     block:^(NSNotification *notification) {
                                                         if (notification.userInfo == nil
                                                             || ![notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
                                                             return;
                                                         }
                                                         
                                                         //NSUInteger rawValue = notification.userInfo[AVAudioSessionInterruptionTypeKey].unsignedIntegerValue;
                                                         NSNumber *interruptType = [notification.userInfo objectForKey:@"AVAudioSessionInterruptionTypeKey"];
                                                         if ([interruptType unsignedIntegerValue] == AVAudioSessionInterruptionTypeBegan) {
                                                             NSLog(@"FlutterInCallManager.AudioSessionInterruptionNotification: Began");
                                                         } else if ([interruptType unsignedIntegerValue] == AVAudioSessionInterruptionTypeEnded) {
                                                             NSLog(@"FlutterInCallManager.AudioSessionInterruptionNotification: Ended");
                                                         } else {
                                                             NSLog(@"FlutterInCallManager.AudioSessionInterruptionNotification: Unknow Value");
                                                         }
                                                         //NSLog(@"RNInCallManager.AudioSessionInterruptionNotification: could not resolve notification");
                                                     }];
    
    _isAudioSessionInterruptionRegistered = YES;
}

- (void)stopAudioSessionInterruptionNotification
{
    if (!_isAudioSessionInterruptionRegistered) {
        return;
    }
    NSLog(@"FlutterInCallManager.stopAudioSessionInterruptionNotification()");
    // --- remove all no matter what object
    [self stopObserve:_audioSessionInterruptionObserver
                 name:AVAudioSessionInterruptionNotification
               object: nil];
    _isAudioSessionInterruptionRegistered = NO;
}

- (void)startAudioSessionRouteChangeNotification
{
    if (_isAudioSessionRouteChangeRegistered) {
        return;
    }
    
    NSLog(@"FlutterInCallManager.startAudioSessionRouteChangeNotification()");
    
    // --- in case it didn't deallocate when ViewDidUnload
    [self stopObserve:_audioSessionRouteChangeObserver
                 name: AVAudioSessionRouteChangeNotification
               object: nil];
    
    _audioSessionRouteChangeObserver = [self startObserve:AVAudioSessionRouteChangeNotification
                                                   object: nil
                                                    queue: nil
                                                    block:^(NSNotification *notification) {
                                                        if (notification.userInfo == nil
                                                            || ![notification.name isEqualToString:AVAudioSessionRouteChangeNotification]) {
                                                            return;
                                                        }
                                                        
                                                        NSNumber *routeChangeType = [notification.userInfo objectForKey:@"AVAudioSessionRouteChangeReasonKey"];
                                                        NSUInteger routeChangeTypeValue = [routeChangeType unsignedIntegerValue];
                                                        
                                                        switch (routeChangeTypeValue) {
                                                            case AVAudioSessionRouteChangeReasonUnknown:
                                                                NSLog(@"FlutterInCallManager.AudioRouteChange.Reason: Unknown");
                                                                break;
                                                            case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
                                                                NSLog(@"FlutterInCallManager.AudioRouteChange.Reason: NewDeviceAvailable");
                                                                if ([self checkAudioRoute:@[AVAudioSessionPortHeadsetMic]
                                                                                routeType:@"input"]) {
                                                                    //                                                                    [self sendEventWithName:@"WiredHeadset"
                                                                    //                                                                                       body:@[@{
                                                                    //                                                                                                  @"isPlugged": @YES,
                                                                    //                                                                                                  @"hasMic": @YES,
                                                                    //                                                                                                  @"deviceName": AVAudioSessionPortHeadsetMic,
                                                                    //                                                                                                  }]];
                                                                } else if ([self checkAudioRoute:@[AVAudioSessionPortHeadphones]
                                                                                       routeType:@"output"]) {
                                                                    //                                                                    [self sendEventWithName:@"WiredHeadset"
                                                                    //                                                                                       body:@[@{
                                                                    //                                                                                                  @"isPlugged": @YES,
                                                                    //                                                                                                  @"hasMic": @NO,
                                                                    //                                                                                                  @"deviceName": AVAudioSessionPortHeadphones,
                                                                    //                                                                                                  }]];
                                                                }
                                                                break;
                                                            case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
                                                                NSLog(@"FlutterInCallManager.AudioRouteChange.Reason: OldDeviceUnavailable");
                                                                if (![self isWiredHeadsetPluggedIn]) {
                                                                    //                                                                    [self sendEventWithName:@"WiredHeadset"
                                                                    //                                                                                       body:@[@{
                                                                    //                                                                                                  @"isPlugged": @NO,
                                                                    //                                                                                                  @"hasMic": @NO,
                                                                    //                                                                                                  @"deviceName": @"",
                                                                    //                                                                                                  }]];
                                                                }
                                                                break;
                                                            case AVAudioSessionRouteChangeReasonCategoryChange:
                                                                NSLog(@"FlutterInCallManager.AudioRouteChange.Reason: CategoryChange. category=%@ mode=%@", _audioSession.category, _audioSession.mode);
                                                                [self updateAudioRoute];
                                                                break;
                                                            case AVAudioSessionRouteChangeReasonOverride:
                                                                NSLog(@"FlutterInCallManager.AudioRouteChange.Reason: Override");
                                                                break;
                                                            case AVAudioSessionRouteChangeReasonWakeFromSleep:
                                                                NSLog(@"FlutterInCallManager.AudioRouteChange.Reason: WakeFromSleep");
                                                                break;
                                                            case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
                                                                NSLog(@"FlutterInCallManager.AudioRouteChange.Reason: NoSuitableRouteForCategory");
                                                                break;
                                                            case AVAudioSessionRouteChangeReasonRouteConfigurationChange:
                                                                NSLog(@"FlutterInCallManager.AudioRouteChange.Reason: RouteConfigurationChange. category=%@ mode=%@", _audioSession.category, _audioSession.mode);
                                                                break;
                                                            default:
                                                                NSLog(@"FlutterInCallManager.AudioRouteChange.Reason: Unknow Value");
                                                                break;
                                                        }
                                                        
                                                        NSNumber *silenceSecondaryAudioHintType = [notification.userInfo objectForKey:@"AVAudioSessionSilenceSecondaryAudioHintTypeKey"];
                                                        NSUInteger silenceSecondaryAudioHintTypeValue = [silenceSecondaryAudioHintType unsignedIntegerValue];
                                                        switch (silenceSecondaryAudioHintTypeValue) {
                                                            case AVAudioSessionSilenceSecondaryAudioHintTypeBegin:
                                                                NSLog(@"FlutterInCallManager.AudioRouteChange.SilenceSecondaryAudioHint: Begin");
                                                            case AVAudioSessionSilenceSecondaryAudioHintTypeEnd:
                                                                NSLog(@"FlutterInCallManager.AudioRouteChange.SilenceSecondaryAudioHint: End");
                                                            default:
                                                                NSLog(@"FlutterInCallManager.AudioRouteChange.SilenceSecondaryAudioHint: Unknow Value");
                                                        }
                                                    }];
    
    _isAudioSessionRouteChangeRegistered = YES;
}

- (void)stopAudioSessionRouteChangeNotification
{
    if (!_isAudioSessionRouteChangeRegistered) {
        return;
    }
    
    NSLog(@"FlutterInCallManager.stopAudioSessionRouteChangeNotification()");
    // --- remove all no matter what object
    [self stopObserve:_audioSessionRouteChangeObserver
                 name:AVAudioSessionRouteChangeNotification
               object:nil];
    _isAudioSessionRouteChangeRegistered = NO;
}

- (void)startAudioSessionMediaServicesWereLostNotification
{
    if (_isAudioSessionMediaServicesWereLostRegistered) {
        return;
    }
    
    NSLog(@"FlutterInCallManager.startAudioSessionMediaServicesWereLostNotification()");
    
    // --- in case it didn't deallocate when ViewDidUnload
    [self stopObserve:_audioSessionMediaServicesWereLostObserver
                 name:AVAudioSessionMediaServicesWereLostNotification
               object:nil];
    
    _audioSessionMediaServicesWereLostObserver = [self startObserve:AVAudioSessionMediaServicesWereLostNotification
                                                             object:nil
                                                              queue:nil
                                                              block:^(NSNotification *notification) {
                                                                  // --- This notification has no userInfo dictionary.
                                                                  NSLog(@"FlutterInCallManager.AudioSessionMediaServicesWereLostNotification: Media Services Were Lost");
                                                              }];
    
    _isAudioSessionMediaServicesWereLostRegistered = YES;
}

- (void)stopAudioSessionMediaServicesWereLostNotification
{
    if (!_isAudioSessionMediaServicesWereLostRegistered) {
        return;
    }
    
    NSLog(@"FlutterInCallManager.stopAudioSessionMediaServicesWereLostNotification()");
    
    // --- remove all no matter what object
    [self stopObserve:_audioSessionMediaServicesWereLostObserver
                 name:AVAudioSessionMediaServicesWereLostNotification
               object:nil];
    
    _isAudioSessionMediaServicesWereLostRegistered = NO;
}

- (void)startAudioSessionMediaServicesWereResetNotification
{
    if (_isAudioSessionMediaServicesWereResetRegistered) {
        return;
    }
    
    NSLog(@"FlutterInCallManager.startAudioSessionMediaServicesWereResetNotification()");
    
    // --- in case it didn't deallocate when ViewDidUnload
    [self stopObserve:_audioSessionMediaServicesWereResetObserver
                 name:AVAudioSessionMediaServicesWereResetNotification
               object:nil];
    
    _audioSessionMediaServicesWereResetObserver = [self startObserve:AVAudioSessionMediaServicesWereResetNotification
                                                              object:nil
                                                               queue:nil
                                                               block:^(NSNotification *notification) {
                                                                   // --- This notification has no userInfo dictionary.
                                                                   NSLog(@"FlutterInCallManager.AudioSessionMediaServicesWereResetNotification: Media Services Were Reset");
                                                               }];
    
    _isAudioSessionMediaServicesWereResetRegistered = YES;
}

- (void)stopAudioSessionMediaServicesWereResetNotification
{
    if (!_isAudioSessionMediaServicesWereResetRegistered) {
        return;
    }
    
    NSLog(@"FlutterInCallManager.stopAudioSessionMediaServicesWereResetNotification()");
    
    // --- remove all no matter what object
    [self stopObserve:_audioSessionMediaServicesWereResetObserver
                 name:AVAudioSessionMediaServicesWereResetNotification
               object:nil];
    
    _isAudioSessionMediaServicesWereResetRegistered = NO;
}

- (void)startAudioSessionSilenceSecondaryAudioHintNotification
{
    if (_isAudioSessionSilenceSecondaryAudioHintRegistered) {
        return;
    }
    
    NSLog(@"FlutterInCallManager.startAudioSessionSilenceSecondaryAudioHintNotification()");
    
    // --- in case it didn't deallocate when ViewDidUnload
    [self stopObserve:_audioSessionSilenceSecondaryAudioHintObserver
                 name:AVAudioSessionSilenceSecondaryAudioHintNotification
               object:nil];
    
    _audioSessionSilenceSecondaryAudioHintObserver = [self startObserve:AVAudioSessionSilenceSecondaryAudioHintNotification
                                                                 object:nil
                                                                  queue:nil
                                                                  block:^(NSNotification *notification) {
                                                                      if (notification.userInfo == nil
                                                                          || ![notification.name isEqualToString:AVAudioSessionSilenceSecondaryAudioHintNotification]) {
                                                                          return;
                                                                      }
                                                                      
                                                                      NSNumber *silenceSecondaryAudioHintType = [notification.userInfo objectForKey:@"AVAudioSessionSilenceSecondaryAudioHintTypeKey"];
                                                                      NSUInteger silenceSecondaryAudioHintTypeValue = [silenceSecondaryAudioHintType unsignedIntegerValue];
                                                                      switch (silenceSecondaryAudioHintTypeValue) {
                                                                          case AVAudioSessionSilenceSecondaryAudioHintTypeBegin:
                                                                              NSLog(@"FlutterInCallManager.AVAudioSessionSilenceSecondaryAudioHintNotification: Begin");
                                                                              break;
                                                                          case AVAudioSessionSilenceSecondaryAudioHintTypeEnd:
                                                                              NSLog(@"FlutterInCallManager.AVAudioSessionSilenceSecondaryAudioHintNotification: End");
                                                                              break;
                                                                          default:
                                                                              NSLog(@"FlutterInCallManager.AVAudioSessionSilenceSecondaryAudioHintNotification: Unknow Value");
                                                                              break;
                                                                      }
                                                                  }];
    _isAudioSessionSilenceSecondaryAudioHintRegistered = YES;
}

- (void)stopAudioSessionSilenceSecondaryAudioHintNotification
{
    if (!_isAudioSessionSilenceSecondaryAudioHintRegistered) {
        return;
    }
    
    NSLog(@"FlutterInCallManager.stopAudioSessionSilenceSecondaryAudioHintNotification()");
    // --- remove all no matter what object
    [self stopObserve:_audioSessionSilenceSecondaryAudioHintObserver
                 name:AVAudioSessionSilenceSecondaryAudioHintNotification
               object:nil];
    
    _isAudioSessionSilenceSecondaryAudioHintRegistered = NO;
}

- (id)startObserve:(NSString *)name
            object:(id)object
             queue:(NSOperationQueue *)queue
             block:(void (^)(NSNotification *))block
{
    return [[NSNotificationCenter defaultCenter] addObserverForName:name
                                                             object:object
                                                              queue:queue
                                                         usingBlock:block];
}

- (void)stopObserve:(id)observer
               name:(NSString *)name
             object:(id)object
{
    if (observer == nil) return;
    [[NSNotificationCenter defaultCenter] removeObserver:observer
                                                    name:name
                                                  object:object];
}

- (NSURL *)getRingbackUri:(NSString *)_type
{
    NSString *fileBundle = @"incallmanager_ringback";
    NSString *fileBundleExt = @"mp3";
    //NSString *fileSysWithExt = @"vc~ringing.caf"; // --- ringtone of facetime, but can't play it.
    //NSString *fileSysPath = @"/System/Library/Audio/UISounds";
    NSString *fileSysWithExt = @"Marimba.m4r";
    NSString *fileSysPath = @"/Library/Ringtones";
    
    // --- you can't get default user perfrence sound in ios
    NSString *type = [_type isEqualToString:@""] || [_type isEqualToString:@"_DEFAULT_"]
    ? fileSysWithExt
    : _type;
    
    NSURL *bundleUri = _bundleRingbackUri;
    NSURL *defaultUri = _defaultRingbackUri;
    
    NSURL *uri = [self getAudioUri:type
                        fileBundle:fileBundle
                     fileBundleExt:fileBundleExt
                    fileSysWithExt:fileSysWithExt
                       fileSysPath:fileSysPath
                         uriBundle:&bundleUri
                        uriDefault:&defaultUri];
    
    _bundleRingbackUri = bundleUri;
    _defaultRingbackUri = defaultUri;
    
    return uri;
}

- (NSURL *)getBusytoneUri:(NSString *)_type
{
    NSString *fileBundle = @"incallmanager_busytone";
    NSString *fileBundleExt = @"mp3";
    NSString *fileSysWithExt = @"ct-busy.caf"; //ct-congestion.caf
    NSString *fileSysPath = @"/System/Library/Audio/UISounds";
    // --- you can't get default user perfrence sound in ios
    NSString *type = [_type isEqualToString:@""] || [_type isEqualToString:@"_DEFAULT_"]
    ? fileSysWithExt
    : _type;
    
    NSURL *bundleUri = _bundleBusytoneUri;
    NSURL *defaultUri = _defaultBusytoneUri;
    
    NSURL *uri = [self getAudioUri:type
                        fileBundle:fileBundle
                     fileBundleExt:fileBundleExt
                    fileSysWithExt:fileSysWithExt
                       fileSysPath:fileSysPath
                         uriBundle:&bundleUri
                        uriDefault:&defaultUri];
    
    _bundleBusytoneUri = bundleUri;
    _defaultBusytoneUri = defaultUri;
    
    return uri;
}

- (NSURL *)getRingtoneUri:(NSString *)_type
{
    NSString *fileBundle = @"incallmanager_ringtone";
    NSString *fileBundleExt = @"mp3";
    NSString *fileSysWithExt = @"Opening.m4r"; //Marimba.m4r
    NSString *fileSysPath = @"/Library/Ringtones";
    // --- you can't get default user perfrence sound in ios
    NSString *type = [_type isEqualToString:@""] || [_type isEqualToString:@"_DEFAULT_"]
    ? fileSysWithExt
    : _type;
    
    NSURL *bundleUri = _bundleRingtoneUri;
    NSURL *defaultUri = _defaultRingtoneUri;
    
    NSURL *uri = [self getAudioUri:type
                        fileBundle:fileBundle
                     fileBundleExt:fileBundleExt
                    fileSysWithExt:fileSysWithExt
                       fileSysPath:fileSysPath
                         uriBundle:&bundleUri
                        uriDefault:&defaultUri];
    
    _bundleRingtoneUri = bundleUri;
    _defaultRingtoneUri = defaultUri;
    
    return uri;
}

- (NSURL *)getAudioUri:(NSString *)_type
            fileBundle:(NSString *)fileBundle
         fileBundleExt:(NSString *)fileBundleExt
        fileSysWithExt:(NSString *)fileSysWithExt
           fileSysPath:(NSString *)fileSysPath
             uriBundle:(NSURL **)uriBundle
            uriDefault:(NSURL **)uriDefault
{
    NSString *type = _type;
    if ([type isEqualToString:@"_BUNDLE_"]) {
        if (*uriBundle == nil) {
            *uriBundle = [[NSBundle mainBundle] URLForResource:fileBundle withExtension:fileBundleExt];
            if (*uriBundle == nil) {
                NSLog(@"RNInCallManager.getAudioUri(): %@.%@ not found in bundle.", fileBundle, fileBundleExt);
                type = fileSysWithExt;
            } else {
                return *uriBundle;
            }
        } else {
            return *uriBundle;
        }
    }
    
    if (*uriDefault == nil) {
        NSString *target = [NSString stringWithFormat:@"%@/%@", fileSysPath, type];
        *uriDefault = [self getSysFileUri:target];
    }
    return *uriDefault;
}

- (NSURL *)getSysFileUri:(NSString *)target
{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:target isDirectory:NO];
    
    if (url != nil) {
        NSString *path = url.path;
        if (path != nil) {
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            BOOL isTargetDirectory;
            if ([fileManager fileExistsAtPath:path isDirectory:&isTargetDirectory]) {
                if (!isTargetDirectory) {
                    return url;
                }
            }
        }
    }
    NSLog(@"FlutterInCallManager.getSysFileUri(): can not get url for %@", target);
    return nil;
}

#pragma mark - AVAudioPlayerDelegate

// --- this only called when all loop played. it means, an infinite (numberOfLoops = -1) loop will never into here.
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag
{
    NSString *filename = player.url.URLByDeletingPathExtension.lastPathComponent;
    NSLog(@"FlutterInCallManager.audioPlayerDidFinishPlaying(): finished playing: %@", filename);
    if ([filename isEqualToString:_bundleBusytoneUri.URLByDeletingPathExtension.lastPathComponent]
        || [filename isEqualToString:_defaultBusytoneUri.URLByDeletingPathExtension.lastPathComponent]) {
        //[self stopBusytone];
        NSLog(@"FlutterInCallManager.audioPlayerDidFinishPlaying(): busytone finished, invoke stop()");
        [self stop:@""];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error
{
    NSString *filename = player.url.URLByDeletingPathExtension.lastPathComponent;
    NSLog(@"FlutterInCallManager.audioPlayerDecodeErrorDidOccur(): player=%@, error=%@", filename, error.localizedDescription);
}

@end

