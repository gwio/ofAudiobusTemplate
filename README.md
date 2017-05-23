# ofAudiobusTemplate
- openFrameworks, inter app audio, audiobus, ios

- This is a quick template project file for integrating audiobus and inter-app-audio into openFrameworks.

- Works with of 0.9.8 and the Audiobus 2.x sdk. But an update to 3. should work too.

- I added a life cycle to suspend the sound when not connected to anything via Audiobus or Inter-App Audio.

- This setup should work "OK" in most cases. I tested it in combination with GarageBand and the Audiobus3 App with some Fx apps but only using a Sender-Port. 

- Issues: Just a small problem, when the OF-App is already running and not started from within Audiobus: In that case any FX app that tries to connect to it produces a audio freeze. No issues when loading the FX first and then plugging the OF App in.

---
You will need to replace the key with a new one from https://developer.audiob.us/


If you create a project from scratch, you will need to got to xcode->capabilities and activate Background Modes - Audio and Inter-App Audio. Edit the Info plist, adding the AudioComponents description and set "App does not run in background" to NO.

When using the background mode, the ofApp->update thread will pause. So if you have a audio control chain already running in a different thread, like pd or so, it should continue to produce sound. Otherwise you will need to extend a class with ofThread, like in the example, to access stuff outside your audio thread. 
