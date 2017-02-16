//
//  XcodeProject.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/22/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

//TODO: write failure tests to get better code coverage

import Foundation
import SynchronousProcess

struct Xcode {
    
    var currentDocumentScript: NSAppleScript?
    var currentDocument: XCDocumentable?
    
    init() {
        currentDocumentScript = createScript()
        if currentDocumentScript == nil{
            print("Failed to create NSAppleScript")
        }
    }
    private func createScript() -> NSAppleScript? {
        let text = "tell application \"Xcode\"\nget path of first document\nend tell"
        return NSAppleScript(source: text)
    }

    private func getCurrentDocumentPath() -> String? {
        guard let scriptObject = currentDocumentScript else {
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
    func getCurrentDocumentable() -> XCDocumentable? {
        guard let path = getCurrentDocumentPath() else {
            return nil
        }
        if projectIsWorkspace(projectPath: path) {
            return XCWorkspace(at: path)
        }else{
            return XCProject(at: path)
        }
    }
    func getProjects(from document: XCDocumentable) -> [XCProject]? {
        if let workspace = document as? XCWorkspace {
            return workspace.projects
        }else if let project = document as? XCProject {
            return [project]
        }
        return nil
    }
}
