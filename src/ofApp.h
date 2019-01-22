#pragma once

#include "ofxiOS.h"
#include "controlThread.h"
#include "ABiOSSoundStream.h"

class ofApp : public ofxiOSApp {
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);
    
    void setupAudioStream();
    
    void setBpm(int);
    
    ABiOSSoundStream* stream;
    ABiOSSoundStream* getSoundStream();
    
    void audioOut(ofSoundBuffer & buffer);
    vector <float> audio;
    float volume;
    
    controlThread myControlThread;
    
    int bpm;

};


