//
//  SourceEditorCommand.swift
//  SourceExtension
//
//  Created by Joel Saltzman on 10/30/16.
//  Copyright © 2016 Joel Saltzman. All rights reserved.
//

import Foundation
import XcodeKit
import AppKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        defer {
            completionHandler(nil)
        }
        NSWorkspace.shared().open(URL.init(string: "xcodehelper://test123")!)
        
/*        guard let url = NSWorkspace.shared().urlForApplication(withBundleIdentifier: "com.joelsaltzman.XcodeHelper") else {
            print("Couldn't find URL")
            return
        }
        
        let options: NSWorkspaceLaunchOptions = NSWorkspaceLaunchOptions()
        
        var configuration: [String: Any] = [String: Any]()
        configuration["foo"] = "bar"
        configuration[NSWorkspaceLaunchConfigurationArguments] = ["foobar"]
        configuration[NSWorkspaceLaunchConfigurationEnvironment] = ["innerFoo" : "innerBar"]
        
        do {
            try NSWorkspace.shared().launchApplication(at: url, options: options, configuration: configuration)
        } catch {
            print("Failed")
        }
        return 
*/ 
        
        //the extension seems to have a problem with apple script getting the info from xcode
        //the main application doesn't
//        print("perform")
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        do {
            //let myAppleScript = "/Users/joelsaltzman/Sites/XcodeHelperSourceExtension/XcodeHelper/SourceExtension/GetCurrentDocument.scpt"
            //let text = try String.init(contentsOfFile: myAppleScript)
            let text = "tell application \"Xcode\"\nget path of first document\nend tell"

            var error: NSDictionary?
            print("creating NSAppleScript")
            if let scriptObject = NSAppleScript(source: text) {
                print("preparing to execute")
                let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&error)
                try output.stringValue?.data(using: String.Encoding.utf8)?.write(to: URL.init(fileURLWithPath: "/Users/joelsaltzman/Downloads/!!!Editor.txt"))
                print("Output: \(output.stringValue)")
                if (error != nil) {
                    print("error: \(error)")
                }
                print("done executing")
            }else{
                print("Failed to create NSAppleScript")
            }
            
            print("done")
        }catch let e {
            print("error: \(e)")
        }

    }
    
}
