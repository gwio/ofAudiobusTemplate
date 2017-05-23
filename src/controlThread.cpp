#include "controlThread.h"

controlThread::controlThread(){
    
}

void controlThread::setup(float* vol_){
    volumePtr = vol_;
    startThread();
}

void controlThread::threadedFunction(){
    while(isThreadRunning()){
        *volumePtr = abs(sin(ofGetElapsedTimef()));
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
