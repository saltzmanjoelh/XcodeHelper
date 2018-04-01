//
//  SourceEditorCommand.swift
//  SourceExtension
//
//  Created by Joel Saltzman on 10/30/16.
//  Copyright © 2016 Joel Saltzman. All rights reserved.
//

import Foundation
import XcodeKit
import XcodeHelperKit
import XcodeHelperCliKit
import AppKit


class SourceEditorCommand: NSObject, XCSourceEditorCommand {
//    let commandRunner = CommandRunner()
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        defer {
            completionHandler(nil)
        }
        guard let commandIdentifier = invocation.commandIdentifier.components(separatedBy: ".").last/*,
            let command = Command.init(rawValue: commandIdentifier)*/
            else{
                return
        }
        //Xcode will only run sandboxed extensions. Can't do something like this because we won't have permission
        //to read the files at the path
//        commandRunner.run(command, atSourcePath: "/Users/joelsaltzman/Sites/hangar_rig/ethosManager")*/
        //We use the main app which is not sandboxed to get file access
        NSWorkspace.shared.open(URL.init(string: "xcodehelper://\(commandIdentifier)")!)
        
    }
    
}
