//
//  main.swift
//  xchelperxpc
//
//  Created by Joel Saltzman on 4/6/18.
//  Copyright © 2018 Joel Saltzman. All rights reserved.
//

import Foundation
import XcodeHelperKit

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
            //show full log message
            //            [[NSWorkspace sharedWorkspace] openFile:@"/Myfiles/README"
            //                withApplication:@"TextEdit"];
            if let filePath = notification.identifier,
                let sourcePath = commandRunner.xcode.getCurrentDocumentable(using: commandRunner.xcode.currentDocumentScript)?.getSourcePath(),
                let logsDirectory = URL.init(string: sourcePath)?.appendingPathComponent(XcodeHelper.logsSubDirectory) {
//                NSWorkspace.shared.openFile("\(filePath).log", withApplication: "Console")
//                let logger = Logger(directory: logsDirectory)
//                logger.showLogs(atPath: filePath /*logsDirectory.appendingPathComponent("\(filePath).log").path*/)
//                showLogs(logsDirectory)
                print("SHOW LOGS: \(logsDirectory)")
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
}

// Create the listener and resume it:
//
let delegate = ServiceDelegate()
let listener = NSXPCListener.service()
NSUserNotificationCenter.default.delegate = delegate
listener.delegate = delegate;
listener.resume()
