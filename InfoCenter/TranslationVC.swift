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
    var url : URL? //holds the URL to the file that is being sent to V4
    var filePath : URL?
    var silenceTimer = Timer()
    var audioFile : AVAudioFile?
    
    //vars for get tokens
    let scope = "http://api.microsofttranslator.com"
    let client_id = "_MSTS2S_App"
    let client_token = "e83e7cc287e04b5dad361823bc3b70fd"
    var token = String() //token that comes back from ADM
    
    var socket: WebSocket!
    
    var customerLanguage = String() //set by button
    var features = String() //set by Setting option
    
    var oldStringFromWebView = ""
    var newStringFromWebView = ""
    
    var lastSpeaker = "no"
    
    
    //*****IBACTION
    @IBAction func home(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "home", sender: sender)
    }
    
    
    @IBAction func talkOne(_ sender: AnyObject) {
        statusField.text = "Listening"
        recordSound()
        lastSpeaker = "yes"
    }
    
    
    @IBAction func doneTalking(_ sender: AnyObject) {
        if audioRecorder?.isRecording != nil {
            self.audioRecorder!.stop()
            getToken()
        }
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
        
        self.silenceTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(TranslationVC.refreshWebView), userInfo: nil, repeats: true)
        
        statusField.text = "Waiting"
        
        postWebserver(" ")
        
    }
    
    
    //*****BEGIN RECORDING SECTION
    func recordSound(){
        
        if ((audioRecorder?.isRecording) != nil) {
            stop()
        }
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "my_audio.wav"
        
        self.filePath = URL.init(fileURLWithPath:dirPath)
        self.filePath?.appendPathComponent(recordingName, isDirectory: false)
        
        let recordSettings = [
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue, //changed from .Min
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 16000.0             ] as [String : Any]
        
        print(filePath!)
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            self.audioRecorder = try AVAudioRecorder(url: self.filePath!, settings: recordSettings as [String : AnyObject])
            
            self.url = filePath //assign path to viewcontroller scoped var
            
        } catch _ {
            print("Error")
        }
        
        self.audioRecorder!.isMeteringEnabled = true
        self.audioRecorder!.prepareToRecord()
        self.audioRecorder!.record()
        
        //check to see if file exists
        let checkValidation = FileManager.default
        
        if (checkValidation.fileExists(atPath: self.filePath!.absoluteString)) {
            print("FILE AVAILABLE")
            print("file size", sizeForLocalFilePath(filePath!.absoluteString))
        } else {
            print("FILE NOT AVAILABLE")
        }
        //end file existance check
    }
    
    
    func sizeForLocalFilePath(_ filePath:String) -> UInt64 {
        
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = fileAttributes[FileAttributeKey.size]  {
                return (fileSize as! NSNumber).uint64Value
            } else {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
    
    
    func stop() {
        
        self.audioRecorder?.stop()
        print("audio recorder stopped")
        
    }
    
    //*****END RECORDING SECTION
    
    
    //*****GET TOKEN and start translation...
    func getToken() -> Void {
        
        self.statusField.text = "Translating"
        
        var clientKey = client_token
        let request = NSMutableURLRequest(url: URL(string: "https://api.cognitive.microsoft.com/sts/v1.0/issueToken?" )!)
        request.setValue(clientKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.httpMethod = "POST"
        request.httpBody = "{body}".data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
                print("error=\(error)")
                self.statusField.text = "error"
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            // Should validate the token...
            if self.validateToken(token: responseString as! String)==false {
                print("error=\(responseString)")
                self.statusField.text = "error"
                return
            }
            
            defer {
                self.token = responseString as! String
                self.connectWebsocket() //start the connection to the websocket
            }
        }
        task.resume()
    }
    func validateToken(token:String) -> Bool {
        let components = token.components(separatedBy: ".")
        if components.count != 3 {
            return false
        }
        if token.hasPrefix("{") {
            return false
        }
        // More validation required to check expiration time...
        
        // skiping it
        return true
    }
    
    
    //*****CREATE WAV FILE HEADER
    func getFileHeader(_ leng: Int, samlpleRate: Int, byteRate: Int) -> [UInt8]{
        
        var header: [UInt8] = [UInt8](repeating: 0, count: 44)
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

//*****BEGIN Extension section for Web Socket Methods
extension TranslationVC : WebSocketDelegate {
    
    
    func connectWebsocket() {
        
        let to = toLanguage
        let from = self.customerLanguage
        
        let features = "Partial"
        let url = URL(string: "wss://dev.microsofttranslator.com/speech/translate?from=" + from + "&to=" + to + "&features=" + features + "&api-version=1.0")
        
        socket = WebSocket(url:url!)
        
        socket.headers["Authorization"] = "Bearer " + (token as String)
        socket.headers["X-ClientAppId"] = "{ea66703d-90a8-436b-9bd6-7a2707a2ad99}"  // ANY IDENTIFIER
        socket.headers["X-CorrelationId"] = "213091F1CF4aaD"    // ANY VALUE
        socket.delegate = self
        socket.connect() //make the socket connection
    }
    func websocketDidConnect(socket ws: WebSocket) {
        print("websocket is connected")
        
        var audioFileBuffer : AVAudioPCMBuffer
        
        // *************OPEN RECORDED FILE FOR READING AND CHUNKING TO SEND TO SERVICE
        do {
            self.audioFile = try AVAudioFile.init(forReading: self.filePath!, commonFormat: .pcmFormatInt16, interleaved: false) //open the audio file for reading
            
            print("this is the file that is sent", self.filePath! )
            print(audioFile!.processingFormat)
            
        }
        catch {
            print("error reading file")
            // Handle error...
        }
        
        audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFile!.processingFormat, frameCapacity: UInt32(audioFile!.length))
        
        do {
            try audioFile!.read(into: audioFileBuffer)
        }
        catch {
            print("error loading buffer")
            // Handle error
        }
        
        let channels = UnsafeBufferPointer(start: audioFileBuffer.int16ChannelData, count: 1)
        let length = Int(audioFileBuffer.frameCapacity * audioFileBuffer.format.streamDescription.pointee.mBytesPerFrame)
        let audioData = Data(bytes: channels[0], count: length)
        
        // send header
        var header = getFileHeader(length, samlpleRate: 16000, byteRate: 32000)  //PASS DATA FOR HEADER AND RETURN HEADER
        
        print(header)
        print(Data(bytes: &header, count: 44))
        
        socket.write(data: Data(bytes: &header, count: header.count))
        usleep(100000)
        
        // send chunks
        let sep = 6144
        let num = length/sep
        
        
        if length > 64632 {  //in case nothing is recorded
            
            for i in 1...(num+1) {
                let subData = audioData.subdata(in: (i-1)*sep..<((i-1)*sep + length))
                socket.write(data: subData)
                usleep(100000) //sleep in microseconds
                
            }
            
            // send blank
            var raw_b = 0b0
            let data_b = NSMutableData(bytes: &raw_b, length: MemoryLayout<NSInteger>.size)
            for _ in 0...11000 {
                data_b.append(&raw_b, length: MemoryLayout<NSInteger>.size)
            }
            
            print("send blank", data_b.length)
            socket.write(data: data_b as Data)
            
        } else {
            self.statusField.text = "Waiting" //change status
            socket.disconnect()
        }
    }
    
    
    func websocketDidDisconnect(socket ws: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
        self.statusField.text = "Waiting"
    }
    
    func websocketDidReceiveMessage(socket ws: WebSocket, text: String) {
        
        var messageType = String()
        var recognition = String()
        var translation = String()
        var htmlString : String!
        let finalText = text.data(using: String.Encoding.utf8)
        
        
        //PARSE JSON
        do {
            let jsonString = try JSONSerialization.jsonObject(with: finalText!, options: .allowFragments) as? [String:Any]
            
            print("********")
            print("this is the full string----->", jsonString as Any)
            print("********")
            
            messageType = (jsonString?["type"] as? String)!
            
            //this section displays partials to the textviw
            if messageType == "partial" {
                recognition = (jsonString?["recognition"] as? String)!
                recognizedText.text = recognition
            }
            
            if messageType == "final" {
                
                translation = (jsonString?["translation"] as? String)!
                recognition = (jsonString?["recognition"] as? String)!
                
            }
            
        } catch {
            print("error serializing")
        }
        
        defer {
            
            if messageType == "final" {
                
                //The statement below changes the textview to append data to the view rather than replacing what was there.
                //recognizedText.text = recognizedText.text.stringByAppendingString(recognition + "\n\n")
                
                recognizedText.text = recognition
                postWebserver(translation)
                socket.disconnect()
                
            }
            
        }
        
    }
    
    
    //This is for playing the voice data - This functionality is not used in the app.
    func websocketDidReceiveData(socket ws: WebSocket, data: Data) {
        
        let length = data.count //length of chunk
        print("Received audio data: \(length)")
        
        /// var audioArrayChunk = [UInt32](repeating: 0, count: length) //create array
        
    }
    
    
    func postWebserver( _ translationString : String) {
        
        
        var translationUrl: String = "https://infocenterserver.azurewebsites.net/api/products" + "?id=" + translationString
        
        translationUrl = translationUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        
        let myUrl: URL = URL(string: translationUrl)!
        
        let request = NSMutableURLRequest(url: myUrl)
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            
            if error != nil
            {
                print("error= \(error)")
                
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString)")
            
        })
        
        task.resume()
        
    }
    
    func refreshWebView() {
        
        translatedWebView.loadRequest(URLRequest(url: URL(string: "https://infocenterserver.azurewebsites.net/index.aspx")!))
        
        newStringFromWebView = translatedWebView.stringByEvaluatingJavaScript(from: "document.body.innerText") as String!
        
        if newStringFromWebView != oldStringFromWebView {
            
            if lastSpeaker == "no" {
                
                getVoice(newStringFromWebView)
                
            } else {
                lastSpeaker = "no"
            }
        } else {
            
        }
        
        defer {
            oldStringFromWebView = newStringFromWebView
        }
    }
    
    
    func getVoice(_ translationToVoice : String) {
        
        var translatedString = translationToVoice //passed in string
        let quality = "MinSize"
        let to = self.customerLanguage
        print(toVoice)
        let customAllowedSet = CharacterSet(charactersIn:" _!*'();:@$,#[]+=/").inverted
        
        translatedString = translatedString.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
        
        let request = NSMutableURLRequest(url: URL(string: "https://api.microsofttranslator.com/V2/Http.svc/Speak?text=\(translatedString)&language=\(to)&options=\(quality)" )!)
        request.httpMethod = "GET"
        
        request.addValue(self.token, forHTTPHeaderField:"Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("this is the reponse from the speakmethod", responseString!)
            
            
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
        })
        
        task.resume()
        
    }
}











