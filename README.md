# ofAudiobusTemplate
openFrameworks, inter app audio, audiobus, ios

This is a quick template project file for integrating audiobus and inter-app-audio into openFrameworks. 

You will need to replace the key with a new one from https://developer.audiob.us/

--

If you create a project from scratch, you will need to got to xcode->capabilities and activate Background Modes - Audio and Inter-App Audio. Edit the Info plist, adding the AudioComponents description and set "App deos not run in background" to NO.

When using the background mode, the ofApp->update thread will pause. So if you have a audio control chain already running in a different thread, like pd or so, it should continue to produce sound. Otherwise you will need to extend a class with ofThread, like in the example, to access stuff outside your audio thread. 
