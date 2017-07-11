//
//  ViewController.swift
//  MDictionary
//
//  Created by liwenqiu on 09/07/2017.
//  Copyright © 2017 liwenqiu. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController {

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var textView: NSTextView!
    
    let youdao = YouDaoService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.textField.becomeFirstResponder()
        
        self.textView.font = NSFont(name: "Menlo", size: 12)
    }
    
    
    @IBAction func query(sender: AnyObject) {
        
        youdao.getQueryResult(q: self.textField.stringValue) { result, error in
            if let error = error {
                print("Error: \(error.message)")
                return
            }
            
            if let result = result {
                var string = ""
                
                if let phonetic = result.phonetic {
                    string += "[\(phonetic)] "
                }
                if let ukPhonetic = result.ukPhonetic {
                    string += "英 [\(ukPhonetic)] "
                }
                if let usPhonetic = result.usPhonetic {
                    string += "美 [\(usPhonetic)] "
                }
                
                string += "\n\n"
                
                if let explaims = result.explains {
                    explaims.forEach { string += $0; string += "\n" }
                }
        
                DispatchQueue.main.async {
                    self.textView.string = string
                    
                }
            }
        }
        
    }
    

    
    @IBAction func quit(sender: AnyObject) {
        NSApplication.shared().terminate(sender)
    }
}

