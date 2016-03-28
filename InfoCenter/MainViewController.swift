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

var toLanguage = "de-DE"
var fromLanguage = "en-US"


class MainViewController: UIViewController {

    
    
    var customerLanguage = String() //set by button
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "cityscape1024x768 v1.jpg")!)
    }
    
    
    
    
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
    
    @IBAction func settings(sender: AnyObject) {
        
        performSegueWithIdentifier("toSettings", sender: sender)
    }
    //*****END IBACTION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toTranslation" {
            let segueToTranslation : TranslationVC = segue.destinationViewController as! TranslationVC
            segueToTranslation.customerLanguage = customerLanguage
        }
        
        if segue.identifier == "toSettings" {
            print("segue")
        }
                
    }

}











