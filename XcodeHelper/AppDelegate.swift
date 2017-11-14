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
    
    var menuController: StatusMenuController?
    let xcode = Xcode()

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        NSUserNotificationCenter.default.delegate = self
        menuController = StatusMenuController(statusItem: NSStatusBar.system.statusItem(withLength: 30.0),
                                              xcode: xcode)
        let statusItem = menuController!.statusItem
        
        //Handle xcodehelper:// urls
        NSAppleEventManager.shared().setEventHandler(menuController!, andSelector: #selector(StatusMenuController.handleGetURL(event:reply:)), forEventClass: UInt32(kInternetEventClass), andEventID: UInt32(kAEGetURL) )
        
        //Statusbar Icon
        if let image = NSImage.init(named: NSImage.Name(rawValue: "AppIcon")) {
            let percentage: CGFloat = 0.13
            image.size = NSMakeSize(image.size.width * percentage, image.size.height * percentage)
            statusItem.image = image
        }
        
        //Statusbar Menu
        statusItem.menu = menuController!.newStatusMenu()
        
        //Refresh the config file so that the Pref menu controls update
        menuController!.refreshConfig()
    }
    
    
    public func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    public func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        //Only notification action available currenly is to silence user notifications
        switch notification.activationType {
        case .contentsClicked:
            //show full log message
            
            break
        case .actionButtonClicked:
            //silence
            //TODO: update prefs window control
            menuController!.refreshConfig()
            UserDefaults.standard.set(false, forKey: Logger.UserDefaultsKey)
            UserDefaults.standard.synchronize()
            break
        default:
            break
        }
        
    }
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }
}

