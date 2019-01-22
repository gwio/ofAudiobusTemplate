#include "controlThread.h"
#include "ofApp.h"


controlThread::controlThread(){
    
}

void controlThread::setup(float* vol_, ofApp* appPtr_){
    volumePtr = vol_;
    appPtr = appPtr_;

    startThread();
}

void controlThread::threadedFunction(){
    while(isThreadRunning()){
        *volumePtr = abs(sin(ofGetElapsedTimef()*(appPtr->bpm*0.025)));
        //  you might need to adjust the sleeptime for your app
        ofSleepMillis(40);
    }    
}

void controlThread::checkIAAStart(int* b_){
    [appDelegatePtr checkIAACon:b_];
}

void controlThread::checkCon(bool* b_){
    [appDelegatePtr checkCon:b_];
}

void controlThread::showLinkMenu(){
    [appDelegatePtr showLinkSettings];
}
