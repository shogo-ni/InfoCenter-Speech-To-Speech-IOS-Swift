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
    
    var customerLanguage = String() //set language code from button tap
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "cityscape1024x768 v1.jpg")!)
    }
    
    
    //*****IBACTION
    @IBAction func ChineseSimplified(_ sender: AnyObject) {
        
        self.customerLanguage = "zh-CN"
        
        performSegue(withIdentifier: "toTranslation", sender: sender)
    }
    
    @IBAction func English(_ sender: AnyObject) {
        
        self.customerLanguage = "en-US"
        
        performSegue(withIdentifier: "toTranslation", sender: sender)
    }
    
    @IBAction func French(_ sender: AnyObject) {
        
        self.customerLanguage = "fr-FR"
        
        performSegue(withIdentifier: "toTranslation", sender: sender)
    }
    
    @IBAction func German(_ sender: AnyObject) {
        
        self.customerLanguage = "de-DE"
        
        performSegue(withIdentifier: "toTranslation", sender: sender)
    }
    
    @IBAction func Italian(_ sender: AnyObject) {
        
        self.customerLanguage = "it-IT"
        
        performSegue(withIdentifier: "toTranslation", sender: sender)
        
    }
    
    @IBAction func ChineseTraditional(_ sender: AnyObject) {
        
        self.customerLanguage = "zh-TW"
        
        performSegue(withIdentifier: "toTranslation", sender: sender)
        
    }
    
    @IBAction func Arabic(_ sender: AnyObject) {
        
        self.customerLanguage = "ar-EG"
        
        performSegue(withIdentifier: "toTranslation", sender: sender)
    }
    
    @IBAction func Spanish(_ sender: AnyObject) {
        
        self.customerLanguage = "es-ES"
        
        performSegue(withIdentifier: "toTranslation", sender: sender)
        
    }
    
    @IBAction func Portugues(_ sender: AnyObject) {
        
        self.customerLanguage = "pt-BR"
        
        performSegue(withIdentifier: "toTranslation", sender: sender)
    }
    
    @IBAction func settings(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "toSettings", sender: sender)
    }
    
    
    //*****END IBACTION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toTranslation" {
            let segueToTranslation : TranslationVC = segue.destination as! TranslationVC
            segueToTranslation.customerLanguage = customerLanguage
        }
        
        if segue.identifier == "toSettings" {
            print("segue")
        }
                
    }

}











