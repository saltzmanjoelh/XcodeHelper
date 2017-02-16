//
//  CommandHandler.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/14/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import AppKit

@objc
class CommandHandler: NSObject {

    
    @objc
    func handleGetURL(event: NSAppleEventDescriptor, reply:NSAppleEventDescriptor) {
        if let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue {
            print("got urlString \(urlString)")
        }
    }
    
    
    
    func sendNotification(_ title: String, message: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
}
extension CommandHandler: StatusMenuDelegate {

    @IBAction
    func preferences(sender: Any){
        NSApplication.shared().mainWindow?.makeKeyAndOrderFront(nil)
    }
    @IBAction
    func quit(sender: Any){
        NSApp.terminate(nil)
    }
    
    func updateMacOsPackages(){
        print("updateMacOsPackages")
    }
    func updateDockerPackages(){
        print("updateDockerPackages")
    }
    func buildInDocker(){
        print("buildInDocker")
    }
    func symlinkDependencies(){
        
    }
    func createArchive(){
        
    }
    func createXCArchive(){
        
    }
    func uploadArchive(){
        
    }
    func gitTag(){
        
    }
    func createXcarchive(){
        
    }
}
