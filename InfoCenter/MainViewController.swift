//
//  ViewController.swift
//  InfoCenter
//
//  Created by MSTranslatorMac on 12/15/15.
//  Copyright © 2015 MSTranslatorMac. All rights reserved.
//

import UIKit
import AVFoundation
import Starscream

class MainViewController: UIViewController {

    var audioFile : AVAudioFile?
    
    
    
    
    //var tokenNS: NSString! //don't need this I believe *****
    var token = String() //token that comes back from ADM
    var finalToken = String() //token that include bearer information
    
    var customerLanguage = String() //set by button
    var toCustomer = String()   //set by Settings option
    var voiceCustomer = String() // set by Settings option
    
    var fromInfo = String()  //set by Settings Option
    var toInfo = String()   //set by button
    var voiceInfo = String() //set by button
    
    var features = String() //set by Setting option
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "cityscape1024x768 v1.jpg")!)
    }
    
    
    //BEGIN IBOUTLET
    

    
    
    //END IBOUTLET
    
    
    //*****IBACTION
    @IBAction func ChineseSimplified(sender: AnyObject) {
        
        self.customerLanguage = "zh-CN"
        
        performSegueWithIdentifier("toTranslation", sender: sender)
    }
    
    @IBAction func English(sender: AnyObject) {
        
        self.customerLanguage = "en-US"
        
        performSegueWithIdentifier("toTranslation", sender: sender)
    }
    
    @IBAction func French(sender: AnyObject) {
        
        self.customerLanguage = "fr-FR"
        
        performSegueWithIdentifier("toTranslation", sender: sender)
    }
    
    @IBAction func German(sender: AnyObject) {
        
        self.customerLanguage = "de-DE"
        
        performSegueWithIdentifier("toTranslation", sender: sender)
    }
    
    @IBAction func Italian(sender: AnyObject) {
        
        self.customerLanguage = "it-IT"
        
        performSegueWithIdentifier("toTranslation", sender: sender)
        
    }
    
    @IBAction func ChineseTraditional(sender: AnyObject) {
        
        self.customerLanguage = "zh-TW"
        
        performSegueWithIdentifier("toTranslation", sender: sender)
        
    }
    
    @IBAction func Arabic(sender: AnyObject) {
        
        self.customerLanguage = "ar-SA"
        
        performSegueWithIdentifier("toTranslation", sender: sender)
    }
    
    @IBAction func Spanish(sender: AnyObject) {
        
        self.customerLanguage = "es-ES"
        
        performSegueWithIdentifier("toTranslation", sender: sender)
        
    }
    
    @IBAction func Portugues(sender: AnyObject) {
        
        self.customerLanguage = "pt-PT"
        
        performSegueWithIdentifier("toTranslation", sender: sender)
    }
    
    //*****END IBACTION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let segueToTranslation : TranslationVC = segue.destinationViewController as! TranslationVC
        
        segueToTranslation.customerLanguage = customerLanguage
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
                    
                    }
                
            } catch {
                
                print("could not get token because -> \(error)")
            }
        }
        
        task.resume()
        
        
        
        return self.finalToken
    
    }

}











