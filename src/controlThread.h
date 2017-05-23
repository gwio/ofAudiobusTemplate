#pragma once
#include "ofMain.h"
#import "MyAppDelegate.h"


//talks with appDelegate

class controlThread :public ofThread {
    
    
public:
    controlThread();
    void setup(float*);
    void threadedFunction();
    
    float* volumePtr;

    MyAppDelegate *appDelegatePtr = (MyAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    void checkIAAStart(int*);
    void checkCon(bool*);
};

