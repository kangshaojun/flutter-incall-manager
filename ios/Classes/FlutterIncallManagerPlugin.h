#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface FlutterIncallManagerPlugin : NSObject <FlutterPlugin, AVAudioPlayerDelegate, FlutterStreamHandler>
@end
