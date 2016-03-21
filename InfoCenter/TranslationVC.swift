//
//  TranslationVC.swift
//  InfoCenter
//
//  Created by MSTranslatorMac on 2/24/16.
//  Copyright © 2016 MSTranslatorMac. All rights reserved.
//

import UIKit
import Starscream
import AVFoundation


class TranslationVC: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    //recording vars
    var audioPlayer : AVAudioPlayer?
    var audioRecorder : AVAudioRecorder?
    var url : NSURL? //holds the URL to the file that is being sent to V4
    var filePath : NSURL?
    var silenceTimer = NSTimer()
    var soundLevel : Double = 0.0
    var averageDecibalCount = 0 //counter
    
    var audioFile : AVAudioFile?
    
    let scope = "http://api.microsofttranslator.com"
    let client_id = "softbank_MSTS2S_App"
    let grant_type = "client_credentials"
    let client_secret = "h20OvLOmBQchNidp90nbDI5e6jWquVGQNQshmuGiqtw%3D"
    
    var socket: WebSocket!
    
    var token = String() //token that comes back from ADM
    var finalToken = String() //token that include bearer information
    
    var customerLanguage = String() //set by button
    var toCustomer = String()   //set by Settings option
    var voiceCustomer = String() // set by Settings option
    
    var toInfo = String()   //set by button
    var voiceInfo = String() //set by button
    var features = String() //set by Setting option
    var chunckCount = 0
    var audioFileSize = 0
    
    var oldStringFromWebView = ""
    var newStringFromWebView = ""
    
    var lastSpeaker = "no"

    
    //*****IBACTION
    @IBAction func home(sender: AnyObject) {
        
        performSegueWithIdentifier("home", sender: sender)
    }
    
    
    @IBAction func talkOne(sender: AnyObject) {
        
        
        statusField.text = "Listening"
        recordSound()
        lastSpeaker = "yes"
        
        
    }
    
    
    @IBAction func refreshWeb(sender: AnyObject) {
        
        translatedWebView.loadRequest(NSURLRequest(URL: NSURL(string: "https://infocenterserver.azurewebsites.net/index.aspx")!))
        
    }
    
    //*****END IBACTION
    
    
    //*****IBOUTLET
    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var recognizedText: UITextView!
    @IBOutlet weak var translatedWebView: UIWebView!
    @IBOutlet weak var statusField: UITextField!
    //*****END IBOUTLET
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "cityscape1024x768 v1.jpg")!)
        
        self.silenceTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("refreshWebView"), userInfo: nil, repeats: true)
        
        statusField.text = "Waiting"
        
    }

    
    //*****BEGIN RECORDING SECTION
    func recordSound(){
        
        if ((audioRecorder?.recording) != nil) {
            stop()
        }
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let recordingName = "my_audio.wav"
        let path = [dirPath, recordingName]
        self.filePath = NSURL.fileURLWithPathComponents(path)!
        
        let recordSettings = [
            AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue, //changed from .Min
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 16000.0             ]
        
            print(filePath)
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            self.audioRecorder = try AVAudioRecorder(URL: self.filePath!, settings: recordSettings as! [String : AnyObject])
            
            self.url = filePath //assign path to viewcontroller scoped var
            
        } catch _ {
            print("Error")
        }
        
        //self.audioRecorder!.delegate = self
        self.audioRecorder!.meteringEnabled = true
        self.audioRecorder!.prepareToRecord()
        self.audioRecorder!.record()
        
        //timer with callback to check for silence every second
        
        self.silenceTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("checkForSilence"), userInfo: nil, repeats: false)
        self.silenceTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("checkForSilence"), userInfo: nil, repeats: true)
        
        //check to see if file exists
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let fullPath = (paths as NSString).stringByAppendingPathComponent("my_audio.wav")
        
        let checkValidation = NSFileManager.defaultManager()
        
        if (checkValidation.fileExistsAtPath(fullPath)) {
            
            print("FILE AVAILABLE")
            
            print("file size", sizeForLocalFilePath(fullPath))
            
        } else {
        
            print("FILE NOT AVAILABLE")
        }
        //end file existance check
        
        
    }
    
    func checkForSilence() {
        
        audioRecorder?.updateMeters()
        print("sound level is ",audioRecorder?.averagePowerForChannel(0) )
        
        averageDecibalCount++
        

        if audioRecorder?.averagePowerForChannel(0) < -39 { //if less than -50 then it is silence enough. true silence is -160
            print("sound level is ",audioRecorder?.averagePowerForChannel(0) )
            self.audioRecorder!.stop()
            self.silenceTimer.invalidate()
            averageDecibalCount = 0
            getToken()

        }
        
    }
    
    
    //used to gets the size of the file and returns it
    func sizeForLocalFilePath(filePath:String) -> UInt64 {
        
        do {
            let fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(filePath)
            if let fileSize = fileAttributes[NSFileSize]  {
                return (fileSize as! NSNumber).unsignedLongLongValue
            } else {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
    
    
    //*****Play
    func play() {
        
        if (!self.audioRecorder!.recording){
            do {
                try audioPlayer = AVAudioPlayer(contentsOfURL: self.url!)
                audioPlayer!.play()
            } catch {
                
                print("failed to play file")
                
            }
        }
    }
    
    //*****Stop
    func stop() {
        
        self.audioRecorder?.stop()
        print("audio recorder stopped")
        
    }
    
    //*****END RECORDING SECTION
    
    //*****GET TOKEN*****
    func getToken() -> String {
        
        self.statusField.text = "Translating"
        var clientId = "NBCU_MSTS2S_App"
        var clientSecret = "W5YrQ8aOpeZ0+54bkaQa2Dx9cDgvTRiHSZPl8M3yg08="
        var grantType = "client_credentials"
        let url = " "
        var scope = "http://api.microsofttranslator.com"
        let customAllowedSet = NSCharacterSet(charactersInString:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnioqrstuvwxyz0123456789_!*'();:@$,#[]+=/").invertedSet
        
        clientId = clientId.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        clientSecret = clientSecret.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        scope = scope.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        grantType = grantType.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let postString = "grant_type=\(grantType)&client_id=\(clientId)&client_secret=\(clientSecret)&scope=\(scope)"
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13" )!)
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? NSDictionary
                
                defer {
                    self.token = result!["access_token"] as! String
                    self.finalToken = "Bearer " + self.token //configure token
                    self.connectWebsocket() //start the connection to the websocket
                }
                
            } catch {
                
                print("could not get token because -> \(error)")
                return
                
            }
        }
        
        task.resume()
        
        return self.finalToken
        
    }
    
    
    
    //*****CREATE WAV FILE HEADER
    func getFileHeader(leng: Int, samlpleRate: Int, byteRate: Int) -> [UInt8]{
        
        var header: [UInt8] = [UInt8](count : 44, repeatedValue : 0)
        let dataSize = leng + 44
        
        for a in "R".utf8 {
            header[0] = a
        }
        for a in "I".utf8 {
            header[1] = a
        }
        for a in "F".utf8 {
            header[2] = a
        }
        for a in "F".utf8 {
            header[3] = a
        }
        header[4] = numericCast((dataSize & 0xff))
        header[5] = numericCast(((dataSize >> 8) & 0xff))
        header[6] = numericCast(((dataSize >> 16) & 0xff))
        header[7] = numericCast(((dataSize >> 24) & 0xff))
        for a in "W".utf8 {
            header[8] = a
        }
        for a in "A".utf8 {
            header[9] = a
        }
        for a in "V".utf8 {
            header[10] = a
        }
        for a in "E".utf8 {
            header[11] = a
        }
        for a in "f".utf8 {
            header[12] = a
        }
        for a in "m".utf8 {
            header[13] = a
        }
        for a in "t".utf8 {
            header[14] = a
        }
        
        for a in " ".utf8 {
            header[15] = a
        }
        header[16] = 16
        header[17] = 0
        header[18] = 0
        header[19] = 0
        header[20] = 1
        header[21] = 0
        header[22] = numericCast(1)
        header[23] = 0
        header[24] = numericCast((samlpleRate & 0xff))
        header[25] = numericCast(((samlpleRate >> 8) & 0xff))
        header[26] = numericCast(((samlpleRate >> 16) & 0xff))
        header[27] = numericCast(((samlpleRate >> 24) & 0xff))
        header[28] = numericCast((byteRate & 0xff))
        header[29] = numericCast(((byteRate >> 8) & 0xff))
        header[30] = numericCast(((byteRate >> 16) & 0xff))
        header[31] = numericCast(((byteRate >> 24) & 0xff))
        header[32] = numericCast(2 * 8 / 8)
        header[33] = 0
        header[34] = 16
        header[35] = 0
        for a in "d".utf8 {
            header[36] = a
        }
        for a in "a".utf8 {
            header[37] = a
        }
        for a in "t".utf8 {
            header[38] = a
        }
        for a in "a".utf8 {
            header[39] = a
        }
        header[40] = numericCast((leng & 0xff))
        header[41] = numericCast(((leng >> 8) & 0xff))
        header[42] = numericCast(((leng >> 16) & 0xff))
        header[43] = numericCast(((leng >> 24) & 0xff))
        
        return header
    }
    
}

//*****BEGIN WS CONNECTION
extension TranslationVC : WebSocketDelegate {
    
    
    func connectWebsocket() {
        
        //let voice = "de-DE-Katja"
        let to = toLanguage
        let from = self.customerLanguage
        //let features = "Partial,texttospeech"
        let features = "Partial"
        
        //socket = WebSocket(url: NSURL(string: "wss://dev.microsofttranslator.com/api/speech/translate?from=" + from + "&to=" + to + "&voice=" + voice + "&features=" + features)!, protocols: [])
        
        socket = WebSocket(url: NSURL(string: "wss://dev.microsofttranslator.com/api/speech/translate?from=" + from + "&to=" + to + "&features=" + features)!, protocols: [])

        
        socket.headers["Authorization"] = "Bearer " + (token as String)
        socket.headers["X-ClientAppId"] = "{ea66703d-90a8-436b-9bd6-7a2707a2ad99}"
        socket.headers["X-CorrelationId"] = "213091F1CF4aaD"
        socket.delegate = self
        socket.disconnect() //In case the socket is already connected?
        socket.connect() //make the socket connection
    }
    
    
    func websocketDidConnect(ws: WebSocket) {
        
        print("websocket is connected")
        print(ws.headers)
        
        var audioFileBuffer : AVAudioPCMBuffer
        
        // *************OPEN RECORDED FILE FOR READING AND CHUNKING TO SEND TO SERVICE
        
        do {
            self.audioFile = try AVAudioFile.init(forReading: self.filePath!, commonFormat: .PCMFormatInt16, interleaved: false) //open the audio file for reading
            
            print("this is the file that is sent", self.filePath)
            print(audioFile!.processingFormat)
            
        }catch{
            print("error reading file")
        }
        
        audioFileBuffer = AVAudioPCMBuffer(PCMFormat: audioFile!.processingFormat, frameCapacity: UInt32(audioFile!.length))
        
        do {
            
            try audioFile!.readIntoBuffer(audioFileBuffer)
        }catch{
            print("error loading buffer")
        }
        
        
        let channels = UnsafeBufferPointer(start: audioFileBuffer.int16ChannelData, count: 1)
        let length = Int(audioFileBuffer.frameCapacity * audioFileBuffer.format.streamDescription.memory.mBytesPerFrame)
        let audioData = NSData(bytes: channels[0], length:length)
        
        // send header
        var header = getFileHeader(length, samlpleRate: 16000, byteRate: 32000)  //PASS DATA FOR HEADER AND RETURN HEADER
        
        print(header)
        print(NSData(bytes: &header, length: 44))
        
        socket.writeData(NSData(bytes: &header, length: header.count))
        usleep(100000)
        
        // send chunk
        let sep = 32000
        let num = length/sep
        
        if length != 64632 {
            
            for i in 1...(num+1) {
                socket.writeData(audioData.subdataWithRange(NSRange(location:(i-1)*sep, length:sep)))
                print("send ", i)
                usleep(100000) //sleep in microseconds
                
            }
        
            // send blank
            var raw_b = 0b0
            let data_b = NSMutableData(bytes: &raw_b, length: sizeof(NSInteger))
            for _ in 0...10000 {
                data_b.appendBytes(&raw_b, length: sizeof(NSInteger))
            }
        
            print("send blank", data_b.length)
            socket.writeData(data_b)
            
        
            
        } else {
            self.statusField.text = "Waiting" //change status
            socket.disconnect()
        }
        
    }
    
    //****
    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        
        self.chunckCount = 0 //reset the count on disonncet, used in websocketDidReceiveData
        self.audioFileSize = 0 //reset the count on disonncet, used in websocketDidReceiveData
        
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
        
        
        self.statusField.text = "Waiting"
    }
    
    //*****
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
        
        var messageType = String()
        var recognition = String()
        var translation = String()
        var htmlString : String!
        let finalText = text.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        //PARSE JSON
        do {
            let jsonString = try NSJSONSerialization.JSONObjectWithData(finalText!, options: .AllowFragments)
            
            print("********")
            print("this is the full string----->", jsonString)
            print("********")
            
            messageType = (jsonString["type"] as? String)!
            
            if messageType == "final" {
                
                translation = (jsonString["translation"] as? String)!
                recognition = (jsonString["recognition"] as? String)!
                
            }
            
        } catch {
            print("error serializing")
        }
        
        defer {
            
            if messageType == "final" {
                
                recognizedText.text = recognizedText.text.stringByAppendingString(recognition + "\n\n")
                sleep(1)
                postWebserver(translation)
                socket.disconnect()
                
            }
            
        }
        
    }
    
    
    //This is for playing the voice data
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        
        print("Received audio data: \(data.length)")
        
        let length = data.length //length of chunk
        
        var audioArrayHeader = [UInt32](count: length, repeatedValue: 0) //create arrayfor header
        var audioArrayChunk = [UInt32](count: length, repeatedValue: 0) //create array
        
        if self.chunckCount == 0 {
            
            //*****Read size of the overall wave from data in the header
            let offset = 4
            let range = NSRange(location: offset, length: 4) //offset = how far to read into the data, length = how many bytes to get when the offset is reached
            var i = [UInt32](count: 1, repeatedValue:0)
            
            data.getBytes(&i, range: range)
            self.audioFileSize = Int(i[0].littleEndian)// return Int(i[0]) for littleEndian
            print("header info \(self.audioFileSize)")
            
            self.chunckCount = 1 //DOES NOT WORK BECAUSE THERE AUDIO SENT ON FINALThis makes it happen once. Reset in websocketdisconnect
            
            //*****Convert NSdata to byte array*****
            
            data.getBytes(&audioArrayHeader, length:length * sizeof(UInt32))
            
            
            //*****End if*****
            
        }
        //if it is the first chunk then do nothing
        if self.chunckCount != 0 { //append to byte array
            
            data.getBytes(&audioArrayChunk, length:length * sizeof(UInt32))
            
        }
        
    }
    
    func postWebserver( translationString : String) {

        
        var translationUrl: String = "https://infocenterserver.azurewebsites.net/api/products" + "?id=" + translationString
        
        translationUrl = translationUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        
        let myUrl: NSURL = NSURL(string: translationUrl)!
        
        let request = NSMutableURLRequest(URL: myUrl)
        
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil
            {
                print("error= \(error)")
                
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            //self.translatedWebView.loadRequest(NSURLRequest(URL: NSURL(string: "https://infocenterserver.azurewebsites.net/index.aspx")!))
        }
        
        task.resume()
        
    }
    
    func refreshWebView() {
        
        translatedWebView.loadRequest(NSURLRequest(URL: NSURL(string: "https://infocenterserver.azurewebsites.net/index.aspx")!))
        
        newStringFromWebView = translatedWebView.stringByEvaluatingJavaScriptFromString("document.body.innerText") as String!
        
        if newStringFromWebView != oldStringFromWebView {
            
            if lastSpeaker == "no" {
                
            getVoice(newStringFromWebView)
            
            } else {
                lastSpeaker = "no"
            }
        }
            
        oldStringFromWebView = newStringFromWebView
    }
    
    
    func getVoice(translationToVoice : String) {
        
        var translatedString = translationToVoice //passed in string
        let quality = "MinSize"
        let to = fromLanguage
        let customAllowedSet = NSCharacterSet(charactersInString:" _!*'();:@$,#[]+=/").invertedSet
        
        translatedString = translatedString.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.microsofttranslator.com/V2/Http.svc/Speak?text=\(translatedString)&language=\(to)&options=\(quality)" )!)
        request.HTTPMethod = "GET"
        
        request.addValue(self.finalToken, forHTTPHeaderField:"Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("this is the reponse from the speakmethod", responseString)
            print("this is the data from the speakmethod", data)
            
            //PLAY AUDIO
            do {
                self.audioPlayer = try AVAudioPlayer(data:data!)
                self.audioPlayer!.delegate = self
                self.audioPlayer!.prepareToPlay()
                self.audioPlayer!.volume = 3.0
                self.audioPlayer!.play()
            } catch {
                print("error Audio Player")
            }
        }
        
        task.resume()
        
        
    }
}











