
#import "ofxiOSAppDelegate.h"
//#import "ofxiOSViewController.h"
//#import <Foundation/Foundation.h>
#import "Audiobus.h"
#import "ABLLink.h"


@interface MyAppDelegate : ofxiOSAppDelegate

@property (strong, nonatomic) ABAudiobusController *audiobusController;

@property (strong, nonatomic) ABAudioSenderPort * audiobusSender;

@end

