//
//  ViewController.swift
//  MDictionary
//
//  Created by liwenqiu on 09/07/2017.
//  Copyright © 2017 liwenqiu. All rights reserved.
//

import Cocoa

enum LanguageCode {
    case en
    case zh
}

enum PronunciationDialectCode {
    case cm
    case uk
    case us
}

struct DictionaryItem {
    let version:        String
    let query:          String
    let from:           LanguageCode
    let to:             LanguageCode
    
    let explanations:   [String]
    let pronunciations: [PronunciationDialectCode: String]?
    
    
    func joinedPronunciations() -> String? {
        guard let pronunciations = self.pronunciations else { return nil }
        
        var results = [String]()
        
        if let us = pronunciations[PronunciationDialectCode.us] {
            results.append("美 [\(us)]")
        }
        if let uk = pronunciations[.uk] {
            results.append("英 [\(uk)]")
        }
        if let cm = pronunciations[.cm], results.count == 0 {
            results.append("[\(cm)]")
        }
        
        if results.count > 0 {
            return results.joined(separator: " ")
        }
        
        return nil
    }
    
    
    func joinedExplanations() -> String {
        return self.explanations.joined(separator: "\n")
    }
}

typealias QueryError = (message: String, cause: String?)
typealias QueryResult = (DictionaryItem?, QueryError?) -> ()


class PopoverViewController: NSViewController {
    
    let escapeKeyCode: UInt16 = 53

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var textView: NSTextView!
    
    var originalQueryWord = ""
    
    let youdao = YouDaoService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.textView.font = NSFont(name: "Menlo", size: 12)
    }
    
    
    @IBAction func query(sender: AnyObject) {
        
        guard self.textField.stringValue.characters.count > 0 else {
            return
        }
        guard self.textField.stringValue != self.originalQueryWord else {
            return
        }
        
        print("Start Query YouDao")
        self.originalQueryWord = self.textField.stringValue
        youdao.getQueryResult(q: self.textField.stringValue) { item, error in
            if let error = error {
                print("Error: \(error.message)")
                return
            }
            
            if let item = item {
                
                let string: String
                if let pronunciations = item.joinedPronunciations() {
                    string = "\(pronunciations)\n\n\(item.joinedExplanations())"
                } else {
                    string = item.joinedExplanations()
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

extension PopoverViewController: NSPopoverDelegate {
    
    func popoverDidShow(_ notification: Notification) {
        NSApplication.shared().activate(ignoringOtherApps: true)
        
    }
    
    func popoverDidClose(_ notification: Notification) {
        NSApplication.shared().unhideWithoutActivation()
    }
}




