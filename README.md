# InfoCenter
###Microsoft Translator Demonstration App For Tourist Information Centers
The app demonstrates how to use the Microsoft Translator Speech API. It is an IOS app written in *Swift* for the iPad. It is designed for information centers who need langauge translation to support tourists. 

####How it works
The app is designed for use with two iPads. The user selects a 'to' language in 'settings' and then selects the language that they are going to speak from the main screen. The second user does the same.

On the translation screen the user taps the 'Talk' button to start the recording and then speaks their question. When they are done they tap the 'Done Talking' button to stop the recording.

The recording is in the .wav file format. The .wav file is sent to the Microsoft Translator Speech service over a websocket connection for voice recognition and translation.

The recognized text, and the translation is returned to the app over the websocket and displayed on the sending iPad.

The translated text is posted to a web service where both iPads retrieve it and display it. The second user then answers the question sent using the same process that the first user used, and the translated text from the second iPad is picked up by the first iPad from the web service.

A simple way to look at the app; it is an iPad walkie talkie that translates text.

The translated text also is spoken on the iPad using a synthetic voice in the correct accent for the selected language.


####Getting Started
-You will need to setup a subscription with Microsoft Translator. [Click Here] (https://www.microsoft.com/en-us/translator/default.aspx) to get started.

-Speech API documentation can be [found here.] (https://docs.microsofttranslator.com/)
This app posts translations to a webservice. You will need a website to post to, or change the app to post locally to the UIWebView.



#####Setup
The app uses a library for connecting over a websocket. The library is on GitHub and it is called [**StarScream**.] (https://github.com/daltoniam/Starscream)

The iPad graphics are setup for the standard iPad, not the iPad pro.

:+2:

- Start App
- Speak in your langauge
- Translation will be displayed
