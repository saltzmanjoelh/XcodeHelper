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
import ProcessRunner
import XcodeHelperKit
import XcodeHelperCliKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension, NSUserNotificationCenterDelegate {
    
    
    func extensionDidFinishLaunching() {
        NSUserNotificationCenter.default.delegate = self
        // If your extension needs to do any work at launch, implement this optional method.
    }
    public func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool
    {
        return true
    }
    /*
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        return []
    }
    */
    
}
