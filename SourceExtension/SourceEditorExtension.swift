//
//  SourceEditorExtension.swift
//  SourceExtension
//
//  Created by Joel Saltzman on 10/30/16.
//  Copyright © 2016 Joel Saltzman. All rights reserved.
//

import Foundation
import XcodeKit
import AppKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    
    func extensionDidFinishLaunching() {
        // If your extension needs to do any work at launch, implement this optional method.
        print("extensionDidFinishLaunching")
        DispatchQueue.main.async {
            
            let script = NSAppleScript(source: "display notification \"SourceEditorCommand\" with title \"SourceEditorCommand\"")!
            print(script)
            var error: NSDictionary?
            let output: NSAppleEventDescriptor = script.executeAndReturnError(&error)
            print(output)
            if (error != nil) {
                print("error: \(String(describing: error))")
            }
        }
    }
    
    
    /*
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        return []
    }
    */
    
}
