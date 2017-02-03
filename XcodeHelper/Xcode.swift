//
//  XcodeProject.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/22/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation
import SynchronousProcess

struct Xcode {
    
    var currentProjectScript: NSAppleScript?
    
    init() {
        
        currentProjectScript = createScript()
        if currentProjectScript == nil{
            print("Failed to create NSAppleScript")
        }
    }
    func getCurrentProject() -> XCProjectable? {
        guard let path = getCurrentProjectPath() else {
            return nil
        }
        if projectIsWorkspace(projectPath: path) {
            return XCWorkspace(at: path)
        }else{
            return XCProject(at: path)
        }
    }
    
    private func createScript() -> NSAppleScript? {
        let text = "tell application \"Xcode\"\nget path of first document\nend tell"
        return NSAppleScript(source: text)
    }

    private func getCurrentProjectPath() -> String? {
        guard let scriptObject = currentProjectScript else {
            return nil
        }
        
        var error: NSDictionary?
        let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&error)
        if (error != nil) {
            print("error: \(error)")
            return nil
        }
        return output.stringValue
    }
    private func projectIsWorkspace(projectPath: String) -> Bool {
        return projectPath.hasSuffix("xcworkspace")
    }
    
    
}
