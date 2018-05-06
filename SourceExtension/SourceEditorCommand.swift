//
//  SourceEditorCommand.swift
//  SourceExtension
//
//  Created by Joel Saltzman on 10/30/16.
//  Copyright © 2016 Joel Saltzman. All rights reserved.
//

import Foundation
import AppKit
import XcodeKit
import ProcessRunner

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    let xpcConnection = NSXPCConnection.init(serviceName: "com.joelsaltzman.xchelperxpc")
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        defer {
            completionHandler(nil)
        }
        guard let commandIdentifier = invocation.commandIdentifier.components(separatedBy: ".").last else{ return }
        
        //Xcode will only run sandboxed extensions. Can't do something like this because we won't have permission
        //to read the files at the path
        //commandRunner.run(command, atSourcePath: "/Users/joelsaltzman/Sites/hangar_rig/ethosManager")
        //XPC seems like a good choice here. The xcode extension simply acts as a UI piece inside xcode
        //when menu items are tiggered, the extension asks the main app to do something.
        //XCP over xcodehelper:// should allow the main app to get triggered without coming to the foreground
        /*if commandIdentifier.contains("docker") {
            //We can't use ProcessRunner for Docker directly because we get permission denied when docker tries to access to docker.sock file
            //We use the main app which is not sandboxed to get file access
            NSWorkspace.shared.open(URL.init(string: "xcodehelper://\(commandIdentifier)")!)
        }else{
            //ProcessRunner.synchronousRun("/Applications/XcodeHelper.app/Contents/Executables/xchelper", arguments: [commandIdentifier, "--chdir", sourcePath])
        }*/
        
        xpcConnection.remoteObjectInterface = NSXPCInterface.init(with: XchelperServiceable.self)
        xpcConnection.exportedObject = self
        xpcConnection.resume()
        if let service = xpcConnection.remoteObjectProxy as? XchelperServiceable {
            service.run(commandIdentifier:  commandIdentifier) { (result) in
                guard let processResult = result as? [String: String] else { return }
                print(processResult)
            }
        }
//        commandRunner.run(commandIdentifier: command.rawValue)
        
    }
    
}
