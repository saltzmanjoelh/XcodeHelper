//
//  main.swift
//  xchelperxpc
//
//  Created by Joel Saltzman on 4/6/18.
//  Copyright © 2018 Joel Saltzman. All rights reserved.
//

import Foundation

class ServiceDelegate : NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with:XchelperServiceable.self)
        let exportedObject = CommandRunner()
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
}

// Create the listener and resume it:
//
try? "main INIT\n".write(to: FileManager.default.temporaryDirectory.appendingPathComponent("xpcmain"), atomically: false, encoding: .utf8)
let delegate = ServiceDelegate()
let listener = NSXPCListener.service()
listener.delegate = delegate;
listener.resume()
