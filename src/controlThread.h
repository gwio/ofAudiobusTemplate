#pragma once
#include "ofMain.h"
#import "MyAppDelegate.h"


//talks with appDelegate

//forward declaration
class ofApp;

class controlThread :public ofThread {
    
    
public:
    controlThread();
    void setup(float*,ofApp*);
    void threadedFunction();
    
    float* volumePtr;
      ofApp* appPtr;

    MyAppDelegate *appDelegatePtr = (MyAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    void checkIAAStart(int*);
    void checkCon(bool*);
    
    void showLinkMenu();

};

