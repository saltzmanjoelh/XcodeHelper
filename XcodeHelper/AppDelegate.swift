//
//  AppDelegate.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 10/30/16.
//  Copyright © 2016 Joel Saltzman. All rights reserved.
//

import Cocoa
import XcodeHelperKit
import os.log

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
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(AppDelegate.handleGetURL(event:reply:)), forEventClass: UInt32(kInternetEventClass), andEventID: UInt32(kAEGetURL) )
        
        //Statusbar Icon
        if let image = NSImage.init(named: "Icon") {
            let percentage: CGFloat = 0.13
            image.size = NSMakeSize(image.size.width * percentage, image.size.height * percentage)
            statusItem.image = image
        }
        
        //Statusbar Menu
        statusItem.menu = menuController!.refreshMenu(nil, currentDocument: nil)
        
        //Refresh the config file so that the Pref menu controls update
        menuController!.refreshConfig()
    }

    @objc
    func handleGetURL(event: NSAppleEventDescriptor, reply:NSAppleEventDescriptor) {
        //xcodehelper://com.joelsaltzman.XcodeHelper.SourceExtension.docker-build
        if let identifier = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
            let commandString = identifier.components(separatedBy: "//").last {
            let command = Command.init(title: "", description: "", cliName: commandString, envName: "")
            menuController?.executeCommand(command)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }
}

