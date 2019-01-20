
#import "MyAppDelegate.h"

#import "ofApp.h"

//#include "ofxiOSExtras.h"
//#include "ofAppiOSWindow.h"

/* You might need to get a temporary key for this app from https://developer.audiob.us/ and maybe
change the AudioComponents Names in the plist to test this on a device */

static NSString *const AUDIOBUS_API_KEY= @"H4sIAAAAAAAAA22OPW/CMBCG/8vNBDcqBZEtGVhZumEUOclBLRLbujujWoj/joMydOhwy/N+3QPwN1hKUEH5tdnnK7c7WEEX3TBi68yEWfKXOg7Wd5G/cQqjEcyWSGPL/Q++Hb2f1sdDUTeFLI61WSKVVlplf/AkDNXpAZLCnDGRrpkvG8dDWzftn/4BuScbxHr3n8yxW3o4OclgMi5eTC+RkDIV5JnekfjdUD7PK7BDVrSaf/RkKBWEV8tCZl7R6oZJq8+PzR6eL/QntikZAQAA:G0ehqg7G3Fn+GHFzkpuYBL/FClylMvCvMqWwChBHvRsTsqpl8ehU1w1JMGFzJtxIC8oI1dv4tTRGQ1RBfFEMy2lPECs8qq8BzBxEjryUVE/W5W73GuxUgLCvEDfuFunL";


@implementation MyAppDelegate

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
    
    
    self.audiobusSender = [[ABAudioSenderPort alloc] initWithName:@"Audio "
                                                       title:NSLocalizedString(@"Out", @"")
                                   audioComponentDescription:(AudioComponentDescription) {
                                       .componentType = kAudioUnitType_RemoteGenerator,
                                       .componentSubType = 'synt', // Note single quotes
                                       //this needs to match the audioComponents entry
                                       .componentManufacturer = 'test' }
                                                   audioUnit:stream.audioUnit];
    [_audiobusController addAudioSenderPort:_audiobusSender];
    
    
    return YES;
    
}

//app life cycle
- (void)applicationDidEnterBackground:(UIApplication *)application {
    //I think this should stop the gl rendering in the background-mode, i have less cpu usage with this
    [ofxiOSGetGLView() stopAnimation];
    glFinish();
    //only continue to generate sound when not connected to anything, maybe this needs a check for inter app audio too, but it works with garageband
    if (!_audiobusController.connected) {
        AudioOutputUnitStop(dynamic_cast<ofApp*>(ofGetAppPtr())->getSoundStream()->getSoundOutStream().audioUnit);
        [[AVAudioSession sharedInstance] setActive:NO error:NULL];
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {

    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
    AudioOutputUnitStart(_audiobusSender.audioUnit);
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback withOptions: AVAudioSessionCategoryOptionMixWithOthers error:  NULL];
    
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


@end

