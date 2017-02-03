//
//  AppDelegate.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 10/30/16.
//  Copyright © 2016 Joel Saltzman. All rights reserved.
//

import Cocoa
import XcodeHelperKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    @IBOutlet weak var statusMenu: NSMenu?
    
    let status = NSStatusBar.system().statusItem(withLength: 30.0)
    let commandHandler = CommandHandler()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //Handle xcodehelper:// urls
        NSAppleEventManager.shared().setEventHandler(commandHandler, andSelector: #selector(CommandHandler.handleGetURL(event:reply:)), forEventClass: UInt32(kInternetEventClass), andEventID: UInt32(kAEGetURL) )
        
        //Statusbar Icon
        if let image = NSImage.init(named: "AppIcon") {
            let percentage: CGFloat = 0.13
            image.size = NSMakeSize(image.size.width * percentage, image.size.height * percentage)
            status.image = image
        }
        
        //Statusbar Menu
        status.menu = MenuManager.newStatusMenu(with: commandHandler)
    }
    
    
    public func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

