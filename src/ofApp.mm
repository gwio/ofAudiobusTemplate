#include "ofApp.h"
#include <AVFoundation/AVFoundation.h>


ABiOSSoundStream* ofApp::getSoundStream(){
    return stream;
}

//--------------------------------------------------------------
void ofApp::setupAudioStream(){
    stream = new ABiOSSoundStream();
    
    ofSoundStreamSettings settings;

    settings.setOutListener(this);
    settings.sampleRate = 44100;
    settings.numOutputChannels = 2;
    settings.numInputChannels = 1;
    settings.bufferSize = 512;

    //it seems to work better if you also setup an output channel even without using it.
    stream->setup(settings);
}

//--------------------------------------------------------------
void ofApp::setup(){	

    volume = 0.0;
    
    myControlThread.setup(&volume);
}

//--------------------------------------------------------------
void ofApp::update(){
    
}

//--------------------------------------------------------------
void ofApp::draw(){
	
}

//--------------------------------------------------------------
void ofApp::exit(){
    myControlThread.stopThread();
    ofSoundStreamClose();
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}

//--------------------------------------------------------------
void ofApp::audioOut(ofSoundBuffer & buffer){
    
    
    for (int i = 0; i < buffer.size(); i+=2){
        float sample = ofRandom(0,1)*0.5*volume;
        buffer[i] = sample;
        buffer[i+1] = sample;
    }
    
}
