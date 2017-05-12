
#import "MyAppDelegate.h"

#import "ofApp.h"

//u need to get a key from https://developer.audiob.us/ and rename stuff in the audiocomponents plist
static NSString *const AUDIOBUS_API_KEY= @"MTQ5NTgxODQxMCoqKm9mQXVkaW9idXNUZW1wbGF0ZSoqKm9mVGVtcGxhdGUtMS4wLmF1ZGlvYnVzOi8vKioqW2F1cmcudGVzdC5zbnRoLjFd:OVq7hNBGqxgVKuQF38+Y3r3BYOFJPm66gsyUG1CxPs7Gmp8JVu+OOPGZyZDmBudIxQI3MG7MqsIkt44VNT4fqcG6Riq5N8DX806VPfopTAatobfrNBTq6EFCcP88Y3vK";


@implementation MyAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [super applicationDidFinishLaunching:application];
    ofApp *app = new ofApp();
    self.glViewController = [[ofxiOSViewController alloc] initWithFrame:[[UIScreen mainScreen] bounds] app:app ];
    
    [self.window setRootViewController:self.glViewController];
    
    
    ofOrientation requested = ofGetOrientation();
    UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationPortrait;
    switch (requested) {
        case OF_ORIENTATION_DEFAULT:
            interfaceOrientation = UIInterfaceOrientationPortrait;
            break;
        case OF_ORIENTATION_180:
            interfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        case OF_ORIENTATION_90_RIGHT:
            interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
            break;
        case OF_ORIENTATION_90_LEFT:
            interfaceOrientation = UIInterfaceOrientationLandscapeRight;
            break;
    }
    
    if(!ofDoesHWOrientation) {
        [self.glViewController rotateToInterfaceOrientation:UIInterfaceOrientationPortrait animated:false];
    } else {
        [[UIApplication sharedApplication] setStatusBarOrientation:interfaceOrientation animated:NO];
        [self.glViewController rotateToInterfaceOrientation:interfaceOrientation animated:false];
        ofSetOrientation(requested);
    }
    
    
    app->setup();
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback withOptions: AVAudioSessionCategoryOptionMixWithOthers error:  NULL];
    
    
    SoundOutputStream *stream = app->getSoundStream()->getSoundOutStream();
    self.audiobusSender.audioUnit = stream.audioUnit;
    
    
    
    self.audiobusController = [[ABAudiobusController alloc] initWithApiKey:AUDIOBUS_API_KEY];
    self.audiobusSender = [[ABSenderPort alloc] initWithName:@"Audio "
                                                       title:NSLocalizedString(@"Out", @"")
                                   audioComponentDescription:(AudioComponentDescription) {
                                       .componentType = kAudioUnitType_RemoteGenerator,
                                       .componentSubType = 'snth', // Note single quotes
                                       .componentManufacturer = 'test' }
                                                   audioUnit:stream.audioUnit];
    [_audiobusController addSenderPort:_audiobusSender];
    
    
    
    return YES;
    
}




-(void)applicationWillTerminate:(UIApplication *)application {
    [super applicationWillTerminate:application];
}


@end

