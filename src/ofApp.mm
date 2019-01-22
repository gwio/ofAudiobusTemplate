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
    settings.numInputChannels = 0;
    settings.bufferSize = 512;

    //it seems to work better if you also setup an output channel even without using it.
    stream->setup(settings);
}

//--------------------------------------------------------------
void ofApp::setup(){
    volume = 0.0;
    
    bpm = 0;
    
    myControlThread.setup(&volume, this);
    
    
    ofSetBackgroundColor(ofColor::yellowGreen);
}

//--------------------------------------------------------------
void ofApp::update(){
    
}

//--------------------------------------------------------------
void ofApp::draw(){
    ofSetColor(0, 0, 0);
    ofDrawBitmapString(ofToString(bpm), 100, 100);
    
    ofSetColor(ofColor::blue);
    ofDrawRectangle(0, ofGetWidth()/2, ofGetHeight(), ofGetWidth());
}

//--------------------------------------------------------------
void ofApp::exit(){
    myControlThread.stopThread();
    ofSoundStreamClose();
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    cout << touch.x << endl;
    if ((ofGetWidth()) - touch.x > ofGetWidth()/2 ) {
         myControlThread.showLinkMenu();
    } else {
        int bbb = ofMap(touch.y, 0, ofGetHeight(), 100,200);
        [getSoundStream()->getSoundOutStream() setBpm: bbb];
    }
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

//-----------

void ofApp::setBpm(int _bpm){
    
    bpm = _bpm;
}
