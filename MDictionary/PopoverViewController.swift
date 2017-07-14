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
    @IBOutlet weak var textView:  NSTextView!
    
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
        
        self.originalQueryWord = self.textField.stringValue
        
        youdao.query(self.textField.stringValue) { item, error in
            guard error == nil else {
                self.asynUpdateTextView(content: "\(error!.message)\n\n\(error!.cause ?? "unknown cause")")
                return
            }
            guard let item = item else {
                self.asynUpdateTextView(content: "Not Found")
                return
            }

            let string: String
            if let pronunciations = item.joinedPronunciations() {
                string = "\(pronunciations)\n\n\(item.joinedExplanations())"
            } else {
                string = item.joinedExplanations()
            }
            
            self.asynUpdateTextView(content: string)
        }
        
    }
    
    func asynUpdateTextView(content: String) {
        DispatchQueue.main.async {
            self.textView.string = content
        }
    }
    
    @IBAction func quit(sender: AnyObject) {
        NSApplication.shared().terminate(sender)
    }
    
    @IBAction func showMenu(sender: AnyObject) {
        print("Show Menu")
        if let button = sender as? NSButton {
            let p = NSPoint(x: sender.frame.origin.x, y: sender.frame.origin.y - (sender.frame.height / 2))
            button.menu?.popUp(positioning: nil, at: p, in: button.superview)
        }
    }
    
    @IBAction func openPreferences(sender: AnyObject) {

        NSWorkspace.shared().open(Bundle.main.bundleURL.appendingPathComponent("Contents/Preferences/MDictionaryPreferences.app"))
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




