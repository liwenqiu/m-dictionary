//
//  AppDelegate.swift
//  MDictionary
//
//  Created by liwenqiu on 09/07/2017.
//  Copyright © 2017 liwenqiu. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var popover: NSPopover!
    
    let statusBarItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)

    
    override func awakeFromNib() {
        let statusBarImage = NSImage(named: "status-item-black")!
        statusBarImage.size = NSSize.init(width: 18.0, height: 18.0)
        statusBarImage.isTemplate = true
        
        statusBarItem.image = statusBarImage
        statusBarItem.highlightMode = true
        statusBarItem.button!.action = #selector(togglePopover(sender:))
        
        // MASShortcut
        
        let shortcut = MASShortcut.init(keyCode: UInt(kVK_F6), modifierFlags: NSEventModifierFlags.shift.rawValue)
        MASShortcutMonitor.shared().register(shortcut, withAction: {
            self.togglePopover(sender: self.statusBarItem.button)
        })
    }
 
    
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        popover.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    fileprivate func showPopover(sender: AnyObject?) {
        if let button = sender as? NSButton {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    fileprivate func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
}

