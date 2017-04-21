//
//  Settings.swift
//  InfoCenter
//
//  Created by MSTranslatorMac on 3/4/16.
//  Copyright © 2016 MSTranslatorMac. All rights reserved.
//

import UIKit
import AVFoundation
import Starscream

var toVoice = "fr-FR"

class SettingsViewController: UIViewController {
    
    var customerLanguage = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "cityscape1024x768 v1.jpg")!)
    }
    
    //*****IBACTION
    
    @IBAction func toGerman(_ sender: AnyObject) {
        
        toLanguage = "de-DE"
        toLanguageText.text = "German"
        toVoice = "de-DE"
    }
    
    @IBAction func toEnglish(_ sender: AnyObject) {
        
        toLanguage = "en-US"
        toLanguageText.text = "English"
        toVoice = "en-US"
        print(toLanguage)
    }
    
    @IBAction func toSpanish(_ sender: AnyObject) {
        
        toLanguage = "es-ES"
        toLanguageText.text = "Spanish"
        toVoice = "es-ES"
    }
    
    @IBAction func toFrench(_ sender: AnyObject) {
        
        toLanguage = "fr-FR"
        toLanguageText.text = "French"
        toVoice = "fr-FR"
    }
    
    @IBAction func toItalian(_ sender: AnyObject) {
        
        toLanguage = "it-IT"
        toLanguageText.text = "Italian"
        toVoice = "it-IT"
        print(toVoice)
    }
    
    @IBAction func toPortuguese(_ sender: AnyObject) {
        
        toLanguage = "pt-PT"
        toLanguageText.text = "Portuguese"
        toVoice = "pt-PT"
    }
    
    @IBAction func toArabic(_ sender: AnyObject) {
        
        toLanguage = "ar-SA"
        toLanguageText.text = "Arabic"
        toVoice = "ar-SA"
    }
    
    @IBAction func toChineseSimplified(_ sender: AnyObject) {
        
        toLanguage = "zh-CN"
        toLanguageText.text = "Chinese Simplified"
        toVoice = "zh-CN"
    }
    
    @IBAction func toChineseTraditional(_ sender: AnyObject) {
        
        toLanguage = "zh-TW"
        toLanguageText.text = "Chinese Traditional"
        toVoice = "zh-TW"
    }
    
    @IBAction func toMain(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "toMain", sender: sender)
    }
    
    
    
    //*****END IBACTION
    
    @IBOutlet weak var toLanguageText: UITextField!
    
    
    
    
    
    
}
