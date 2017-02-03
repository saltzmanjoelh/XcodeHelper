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
            print("done!!!")
            completionHandler(nil)
        }
        
        print("starting")
        NSWorkspace.shared().open(URL.init(string: "xcodehelper://test123")!)
        print("done")
        
        //the extension seems to have a problem with apple script getting the info from xcode so we have to simply open an xcode helper URL
//        NSWorkspace.shared().open(URL.init(string: "xcodehelper://test123")!)
        
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
        
        
    }
    
}
