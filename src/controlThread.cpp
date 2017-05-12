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
        cout << *volumePtr << endl;

        ofSleepMillis(40);
    }
    
}

