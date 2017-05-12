#pragma once
#include "ofMain.h"


//talks with appDelegate

class controlThread :public ofThread {
    
    
public:
    controlThread();
    void setup(float*);
    void threadedFunction();
    
    float* volumePtr;
    

};

