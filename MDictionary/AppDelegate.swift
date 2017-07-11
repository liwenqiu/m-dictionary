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
    
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    
    var eventMonitor: EventMonitor?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let icon = NSImage(named: "status-item-black")
        icon?.size = NSSize.init(width: 18.0, height: 18.0)
        icon?.isTemplate = true
        
        statusItem.image = icon
        statusItem.highlightMode = true
        if let button = statusItem.button {
            button.action = #selector(togglePopover(sender:))
        }

        popover.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)

        eventMonitor = EventMonitor(mask: NSEventMask.leftMouseDown.union(.rightMouseDown)) { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(sender: event)
            }
        }
        eventMonitor?.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        eventMonitor?.start()
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
}

