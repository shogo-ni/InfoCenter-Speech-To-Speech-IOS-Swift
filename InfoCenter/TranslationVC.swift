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
    
    
    var audioFile : AVAudioFile?
    
    let scope = "http://api.microsofttranslator.com"
    let client_id = "softbank_MSTS2S_App"
    let grant_type = "client_credentials"
    let client_secret = "h20OvLOmBQchNidp90nbDI5e6jWquVGQNQshmuGiqtw%3D"
    var socket: WebSocket!
    
    
    //var tokenNS: NSString! //don't need this I believe *****
    var token = String() //token that comes back from ADM
    var finalToken = String() //token that include bearer information
    
    var finalString = [String]() //for printing out the final translation
    
    var fromCustomer = String() //set by button
    var toCustomer = String()   //set by Settings option
    var voiceCustomer = String() // set by Settings option
    
    var fromInfo = String()  //set by Settings Option
    var toInfo = String()   //set by button
    var voiceInfo = String() //set by button
    
    var features = String() //set by Setting option
    
    var chunckCount = 0
    var audioFileSize = 0

    
    
    
    //*****IBACTION
    @IBAction func home(sender: AnyObject) {
        
        performSegueWithIdentifier("home", sender: sender)
    }
    
    @IBAction func talkOne(sender: AnyObject) {
        
        
    }
    @IBAction func talkTwo(sender: AnyObject) {
        
        
    }
    //*****END IBACTION
    
    
    //*****IBOUTLET
    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var recognizedText: UITextView!
    
    //*****END IBOUTLET
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "cityscape1024x768 v1.jpg")!)
    }

    
    
    //*****BEGIN RECORDING SECTION
    func recordSound(){
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let recordingName = "my_audio.wav"
        let path = [dirPath, recordingName]
        self.filePath = NSURL.fileURLWithPathComponents(path)!
        
        let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 16000.0]
        
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
        
        //ADD METERING FUNCTIONS TO CHECK FOR SOUND LEVELS - CALL UPDATEMETER() BEFORE CHECKING THE DECIBEL LEVEL - DECIBALS ARE NEGATIVE NUMBERS UP TO ZERO
        //DECIBEL LEVEL -160 IS NEAR TOTAL SILENCE ---- WAIT AT LEAST 1.5 SECONDS BEFORE CHECKING FOR SILENCE - GIVE SOME KIND OF SIGNAL MAYBE SHOW A WAVE SIGN LIKE SIRI
        //IF SOUND LEVELS ARE TOO LOW THEN CALL THE STOP FUNC
        //AFTER STOP THEN CALL THE WS CONNECT FUNC AND THEN OPEN FILE FOR READING AND CHUNKING TO THE SERVICE
        //SHOULD I USE THE TEMP DIR SO THAT IT IS DELETED AFTER THE APP EXITS????????
        //ADD A CASE STATEMENT FOR LANGUAGE SELECTION
        //ADD PORTUGUESE
        
        
        
        //check to see if file exists
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let fullPath = (paths as NSString).stringByAppendingPathComponent("my_audio.wav")
        
        let checkValidation = NSFileManager.defaultManager()
        
        if (checkValidation.fileExistsAtPath(fullPath))
        {
            print("FILE AVAILABLE")
            
            print(sizeForLocalFilePath(fullPath))
        }
        else
        {
            print("FILE NOT AVAILABLE")
        }
        //end file existance check
        
        
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
    
    
    
    
    
    func getToken() -> String {
        
        //*****GET TOKEN*****
        
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
            
            print(data)
            print(response)
            print(error)
            
            if error != nil {
                print("error=\(error)")
                
                return
            }
            
            print("response = \(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? NSDictionary
                print("-----------")
                print("result = \(result!["access_token"])")
                
                defer {
                    self.token = result!["access_token"] as! String
                    self.finalToken = "Bearer " + self.token //configure token
                    print("****>>>>", self.finalToken)
                    self.connectWebsocket()
                }
                
            } catch {
                
                print("could not get token because -> \(error)")
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
        
        //self.toInfo = "en-US"
        let voice = "de-DE-Katja"
        let to = "de-DE"
        let from = "en-US"
        //let features = "Partial,texttospeech"
        let features = "Partial"
        
        socket = WebSocket(url: NSURL(string: "wss://dev.microsofttranslator.com/api/speech/translate?from=" + from + "&to=" + to + "&voice=" + voice + "&features=" + features)!, protocols: [])
        
        
        //socket = WebSocket(url: NSURL(string: "wss://dev.microsofttranslator.com/api/speech/translate?from=" + self.fromCustomer + "&to=" + self.toInfo + "&voice=" + voice + "&features=" + features)!, protocols: [])
        
        //socket = WebSocket(url: NSURL(string: "ws://dev.microsofttranslator.com/api/speech/translate?from=" + self.fromCustomer + "&to=" + self.toInfo + "&features=" + features)!, protocols: [])
        
        //socket.headers["Authorization"] = self.finalToken
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
        //var audioFile : AVAudioFile
        var audioFileBuffer : AVAudioPCMBuffer
        
        //let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        
        //do {
        //let urls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsDirectory, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
        
        //if (urls.isEmpty) {
        //let alert = UIAlertView()
        //alert.message = "record message"
        // alert.addButtonWithTitle("OK")
        //alert.show()
        //return
        //}
        
        
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
        usleep(10000)
        
        // send chunk
        let sep = 32000
        let num = length/sep
        
        for i in 1...(num+1) {
            socket.writeData(audioData.subdataWithRange(NSRange(location:(i-1)*sep, length:sep)))
            print("send ", i)
            usleep(100000)
        }
        
        // send blank
        var raw_b = 0b0
        let data_b = NSMutableData(bytes: &raw_b, length: sizeof(NSInteger))
        for _ in 0...10000 {
            data_b.appendBytes(&raw_b, length: sizeof(NSInteger))
        }
        
        print("send blank", data_b.length)
        socket.writeData(data_b)
        
        //} catch let rangeError as NSException {
        //print("something went wrong listing recordings \(rangeError)")
        //} catch let error as NSError {
        //print(error.localizedDescription)
        //}
        
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
        
        finalString.removeAll()
    }
    
    //*****
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
        
        var messageType = String()
        var translation = String()
        
        
        print("Received text: \(text)")
        
        let finalText = text.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        //PARSE JSON
        do {
            let jsonString = try NSJSONSerialization.JSONObjectWithData(finalText!, options: .AllowFragments)
            
            print("this is the type \(jsonString["type"])")
            
            messageType = (jsonString["type"] as? String)!
            translation = (jsonString["translation"] as? String)!
            
            print("this is the message type --> \(messageType)")
            
            if messageType == "final" {
                print("This is the translation \(jsonString["translation"])")
                self.finalString.append(translation)
                
            }
            
            
        } catch {
            print("error serializing")
        }
        
        print("the final string follows *****")
        print(self.finalString)
        
        let stringToDisplay = self.finalString.joinWithSeparator(" ")
        
        
        
        defer {
            
            //self.translationDisplay.text = stringToDisplay
            //self.translationDisplay.text = self.finalString.joinWithSeparator(" ")
            
            if messageType == "final" {
                
                //Translatorv3(self.translationDisplay.text)
                //Translatorv3(stringToDisplay)
            }
            
        }
        
    }
    
    //This is for playing the voice data
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        
        print("Received audio data: \(data.length)")
        
        let length = data.length //length of chunk
        //var audioData = data
        //var sizeRemaining = Int() //NEED TO MAKE THIS GLOBAL FOR THE VC
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
            
            //audioArray = audioArray + audioArrayHeader
            
            //*****End if*****
            
        }
        //if it is the first chunk then do nothing
        if self.chunckCount != 0 { //append to byte array
            
            data.getBytes(&audioArrayChunk, length:length * sizeof(UInt32))
            //audioArray = audioArray + audioArrayChunk
        }
        
        
        //if audioArray.count > 150000 {   // keep adding chunks until it is about 150000 bytes
        
        //*****Convert Byte array to NSData*****
        //let newLength = audioArray.count
        //let newAudioBytes = NSData(bytes: audioArray as [UInt32], length:newLength)
        
        //   sizeRemaining = audioFileSize - length
        //print("\n" + "Number of bytes in array before conversion \(audioArray.count)")
        //print("\n" + "Number of bytes in NSData NewAudioBytes \(newAudioBytes.length)")
        //   print("size remaining \(sizeRemaining)")
        //print(newAudioBytes)
        
        //    do {
        //self.player = try AVPlayer(playerItem:audioData)
        //self.player = try AVAudioPlayer(data:newAudioBytes)
        //self.player.delegate = self
        //self.player.prepareToPlay()
        //self.player.volume = 5.0
        //self.player.play()
        //audioArray.removeAll()
        //   } catch let e as NSError {
        //       print(e)
        //   }
        
        //} //end if
        
    }
    


}











