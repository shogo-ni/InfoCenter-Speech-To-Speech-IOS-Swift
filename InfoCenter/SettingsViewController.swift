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

class SettingsViewController: UIViewController {
    
    var customerLanguage = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "cityscape1024x768 v1.jpg")!)
    }
    
    //*****IBACTION
    
    @IBAction func toGerman(sender: AnyObject) {
        
        toLanguage = "de-DE"
        toLanguageText.text = "German"
        
    }
    
    @IBAction func toEnglish(sender: AnyObject) {
        
        toLanguage = "en-US"
        toLanguageText.text = "English"
        print(toLanguage)
    }
    
    @IBAction func toSpanish(sender: AnyObject) {
        
        toLanguage = "es-ES"
        toLanguageText.text = "Spanish"
    }
    
    @IBAction func toFrench(sender: AnyObject) {
        
        toLanguage = "fr-FR"
        toLanguageText.text = "French"
    }
    
    @IBAction func toItalian(sender: AnyObject) {
        
        toLanguage = "it-IT"
        toLanguageText.text = "Ialian"
    }
    
    @IBAction func toPortuguese(sender: AnyObject) {
        
        toLanguage = "pt-PT"
        toLanguageText.text = "Portuguese"
    }
    
    @IBAction func toArabic(sender: AnyObject) {
        
        toLanguage = "ar-SA"
        toLanguageText.text = "Arabic"
    }
    
    @IBAction func toChineseSimplified(sender: AnyObject) {
        
        toLanguage = "zh-CN"
        toLanguageText.text = "Chinese Simplified"
    }
    
    @IBAction func toChineseTraditional(sender: AnyObject) {
        
        toLanguage = "zh-TW"
        toLanguageText.text = "Chinese Traditional"
    }
    
    @IBAction func toMain(sender: AnyObject) {
        
        performSegueWithIdentifier("toMain", sender: sender)
    }
    
    
    
    //*****END IBACTION
    
    @IBOutlet weak var toLanguageText: UITextField!
    
    
    
    
    
    
}