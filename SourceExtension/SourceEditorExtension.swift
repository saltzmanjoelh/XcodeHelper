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

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    
    func extensionDidFinishLaunching() {
        // If your extension needs to do any work at launch, implement this optional method.
//        XcodeHelper.logger = Logger(category: Command.updateMacOSPackages.title)
//        XcodeHelper.logger?.logWithNotification("Testing %i %i %i", 1, 2, 3)
    }
    
    
    /*
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        return []
    }
    */
    
}
