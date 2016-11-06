//
//  AppDelegate.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 10/30/16.
//  Copyright © 2016 Joel Saltzman. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let status = NSStatusBar.system().statusItem(withLength: -1.0)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        getCurrentProject()
        return;
        print("Bundle: \(Bundle.main.bundleIdentifier)")
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(self.handleGetURL(event:reply:)), forEventClass: UInt32(kInternetEventClass), andEventID: UInt32(kAEGetURL) )
        getCurrentProject()
        
        status.title = "xchelper"
        //statusItem.image = icon
        //statusItem.menu = mainMenu
        
        //Build in Linux Instructions (help item?)
        //Update Dependencies
        //Increment Git Tag
        //Create & Upload Archive
        
        //BUILD_DIR == .../Build/Products -> ../../Logs/Build
    }
    func handleGetURL(event: NSAppleEventDescriptor, reply:NSAppleEventDescriptor) {
        if let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue {
            print("got urlString \(urlString)")
            
        }
    }
    func getCurrentProject() {
        let text = "tell application \"Xcode\"\nget path of first document\nend tell"
        
        var error: NSDictionary?
        print("creating NSAppleScript")
        if let scriptObject = NSAppleScript(source: text) {
            print("preparing to execute")
            let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&error)
            print("Output: \(output.stringValue)")
            if (error != nil) {
                print("error: \(error)")
            }
            print("done executing")
        }else{
            print("Failed to create NSAppleScript")
        }
        
        print("done")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

