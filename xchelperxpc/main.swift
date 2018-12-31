//
//  main.swift
//  xchelperxpc
//
//  Created by Joel Saltzman on 4/6/18.
//  Copyright © 2018 Joel Saltzman. All rights reserved.
//

import Foundation
import XcodeHelperKit
import AppKit
import ProcessRunner

class ServiceDelegate : NSObject, NSXPCListenerDelegate, NSUserNotificationCenterDelegate {
    let commandRunner = CommandRunner()
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with:XchelperServiceable.self)
        newConnection.exportedObject = commandRunner
        newConnection.resume()
        return true
    }
    public func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    public func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        //Only notification action available currenly is to silence user notifications
        switch notification.activationType {
        case .contentsClicked:
            if let uuidString = notification.identifier,
                let uuid = UUID.init(uuidString: uuidString),
                let timerEntry = Logger.timers[uuid] {
                showLogs(category: timerEntry.identifier.category, pid: timerEntry.identifier.pid)
                NSUserNotificationCenter.default.removeDeliveredNotification(timerEntry.notification)
            }
            break
        case .actionButtonClicked:
            //silence
            //TODO: update prefs window control
//            menuController!.refreshConfig()
            UserDefaults.standard.set(false, forKey: Logger.UserDefaultsKey)
            UserDefaults.standard.synchronize()
            break
        default:
            break
        }
    }
    public func showLogs(category: String, pid: Int32) {
        //applescript to run:
        //log show --style compact --predicate '(subsystem == "com.joelsaltzman.XcodeHelper.plist") && (category == "Update Packages - macOS") && processIdentifier == 18498'
        //archive the logs into a file, then get Console to open the archive
        let result = ProcessRunner.synchronousRun("/usr/bin/log",
                                                     arguments: ["show",
                                                                 "--style",
                                                                 "compact",
                                                                 "--predicate",
                                                                 "(subsystem == \"\(Logger.subsystemIdentifier)\") && (category == \"\(category)\") && processIdentifier == \(pid)"],
                                                     printOutput: true,
                                                     outputPrefix: nil,
                                                     environment: nil)
//        print("RESULT: \(result)")
        let path = "/tmp/XcodeHelper.log"
        if let output = result.output?.replacingOccurrences(of: "Df ", with: "")
            .replacingOccurrences(of: " E  ", with: " ")
            .replacingOccurrences(of: "[\(Logger.subsystemIdentifier):\(category)]", with: "[\(category)]") {
            DispatchQueue.main.async {
                FileManager.default.createFile(atPath: path,
                                               contents: output.data(using: .utf8),
                                               attributes: nil)
                NSWorkspace.shared.openFile(path)
            }
        }
        
    }

}

// Create the listener and resume it:
//
let delegate = ServiceDelegate()
let listener = NSXPCListener.service()
NSUserNotificationCenter.default.delegate = delegate
listener.delegate = delegate;
listener.resume()
