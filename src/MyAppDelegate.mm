
#import "MyAppDelegate.h"

#import "ofApp.h"

//#include "ofxiOSExtras.h"
//#include "ofAppiOSWindow.h"

/* You might need to get a temporary key for this app from https://developer.audiob.us/ and maybe
change the AudioComponents Names in the plist to test this on a device */

static NSString *const AUDIOBUS_API_KEY= @"H4sIAAAAAAAAA32NwQ6CMBBE/2XPaiVgVG7+gzdrSIFVG6FtdrfGhvjvFuNVr29m3kyAz2ApQQ3FptqX22q/q2ABbXT9gI0zI+bIXw6xt76NfMQxDEYwVyINDXc3/NFYFqv1ynxhrZVWeRM8CUN9mkBSmHcm0jXzfz89ckc2iPXuV4Vj+/VxcpLBaFy8mE4iIWUqyDN9IPHHUrzOC7B9TrSSrPFkKC0Jr5aFzPyk1R2TVuV6U8HrDWhCcQElAQAA:kZ2p9Y4IxocAUVhRzfEWeFLQhkVQKMUiw+LhPIuiwo1rup2Q9iyZQP4k2V0aVo0nSnku+klcbYYLwHoln0Fzj/qBhEPUqYgBlUhqw5qux2wE24Y2whn2CJRO3HU0yzwf";


@implementation MyAppDelegate

static void * kAudiobusConnectedChanged = &kAudiobusConnectedChanged;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [super applicationDidFinishLaunching:application];
    ofApp *app = new ofApp();
self.uiViewController = [[ofxiOSViewController alloc] initWithFrame:[[UIScreen mainScreen] bounds] app:app ];
    
    [self.window setRootViewController:self.uiViewController];
    
    /*
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
     */
    
    /*
    if(!ofDoesHWOrientation) {
        [self.glViewController rotateToInterfaceOrientation:UIInterfaceOrientationPortrait animated:false];
    } else {
        [[UIApplication sharedApplication] setStatusBarOrientation:interfaceOrientation animated:NO];
        [self.glViewController rotateToInterfaceOrientation:interfaceOrientation animated:false];
        ofSetOrientation(requested);
    }
    */
    
    // Watch the connected and audiobusAppRunning properties to be notified when we connect/disconnect or Audiobus opens or closes
    [_audiobusController addObserver:self forKeyPath:@"connected" options:0 context:kAudiobusConnectedChanged];
    
    self.audiobusController = [[ABAudiobusController alloc] initWithApiKey:AUDIOBUS_API_KEY];
    self.audiobusController.connectionPanelPosition = ABConnectionPanelPositionTop;
    
    /* you need to setup the OF audiostream to get the audiounit pointer for audiobus, this happens before ofApp->setup() is called. 
     I used a seperate function for this, if you use your ofApp->setup(), setup() gets called 2x and the pointer might not work... 
     You could setup audiobus also later from inside Of, audiobus seems to work, but it did not work for GarageBand (IIA in generall?)*/
     
    app->setupAudioStream();

    SoundOutputStream *stream = app->getSoundStream()->getSoundOutStream();
    
    
    
    /* You need to set the AudioSession settings again, setupSoundStream() I think sets it to AVAudioSessionCategoryPlayAndRecord?
     In any case, without calling this after setupSoundStream i could not start from within Audiobus without sound issues. */
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback withOptions: AVAudioSessionCategoryOptionMixWithOthers  error:  NULL];
    
    
    self.audiobusSender = [[ABAudioSenderPort alloc] initWithName:@"ofAudiobusTemplate"
                                                       title:NSLocalizedString(@"Out", @"")
                                   audioComponentDescription:(AudioComponentDescription) {
                                       .componentType = kAudioUnitType_RemoteGenerator,
                                       .componentSubType = 'synt', // Note single quotes
                                       //this needs to match the audioComponents entry
                                       .componentManufacturer = 'test' }
                                                   audioUnit:stream.audioUnit];
    [_audiobusController addAudioSenderPort:_audiobusSender];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:AVAudioSessionInterruptionNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        NSInteger type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
        if ( type == AVAudioSessionInterruptionTypeBegan ) {
            [self stop];
        } else {
            [self start];
        }
    }];
    
    ofxiOSDisableIdleTimer();

    
    return YES;
    
}

//app life cycle
- (void)applicationDidEnterBackground:(UIApplication *)application {
    //I think this should stop the gl rendering in the background-mode, i have less cpu usage with this
    [ofxiOSGetGLView() stopAnimation];
    glFinish();
    //only continue to generate sound when not connected to anything, maybe this needs a check for inter app audio too, but it works with garageband
    if (!_audiobusController.connected) {
        [self stop];
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self start];
}

//check for iia connection, i had a problem with fbos not working when started from inside garageband...
-(void) checkIAACon:(int *)iaaCon{
    UInt32 connected;
    UInt32 dataSize = sizeof(UInt32);
    AudioUnitGetProperty(_audiobusSender.audioUnit,
                         kAudioUnitProperty_IsInterAppConnected,
                         kAudioUnitScope_Global, 0, &connected, &dataSize);
    *iaaCon = connected;
}

//can be called from controlThread.h to test for connection
-(void) checkCon:(bool *)iaaCon{
    UInt32 connected;
    UInt32 dataSize = sizeof(UInt32);
    AudioUnitGetProperty(_audiobusSender.audioUnit,
                         kAudioUnitProperty_IsInterAppConnected,
                         kAudioUnitScope_Global, 0, &connected, &dataSize);
    if(_audiobusController.connected || connected == 1){
        *iaaCon = true;
    } else {
        *iaaCon = false;
    }
}
-(void)applicationWillTerminate:(UIApplication *)application {
    [super applicationWillTerminate:application];
}

-(void)start{
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
    AudioOutputUnitStart(dynamic_cast<ofApp*>(ofGetAppPtr())->getSoundStream()->getSoundOutStream().audioUnit);
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback withOptions: AVAudioSessionCategoryOptionMixWithOthers error:  NULL];
}

-(void)stop{
    AudioOutputUnitStop(dynamic_cast<ofApp*>(ofGetAppPtr())->getSoundStream()->getSoundOutStream().audioUnit);
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
}

@end

