//
//  Xcode.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/22/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

//TODO: look at datasourcable project to see why no targets are showing up

import Foundation
import ProcessRunner

protocol XCItem: CustomStringConvertible {
    var imagePath: String { get }
}

struct Xcode {
    
    let currentDocumentScript: NSAppleScript
    let currentUser: String = XCWorkspace.getCurrentUser()!
    
    init() {
        currentDocumentScript = NSAppleScript(source: "tell application \"Xcode\"\nget path of first document\nend tell")!
    }

    func getCurrentDocumentPath(using script: NSAppleScript) -> String? {
        var error: NSDictionary?
        let output: NSAppleEventDescriptor = script.executeAndReturnError(&error)
        if (error != nil) {
            print("error: \(String(describing: error))")
            return nil
        }
        return output.stringValue
    }
    func getCurrentDocumentable(using script: NSAppleScript) -> XCDocumentable? {
        guard let path = getCurrentDocumentPath(using: script) else {
            return nil
        }
        if projectIsWorkspace(projectPath: path) {
            return XCWorkspace(at: path, currentUser: currentUser)
        }
        return XCProject(at: path, currentUser: currentUser)
    }
    private func projectIsWorkspace(projectPath: String) -> Bool {
        return projectPath.hasSuffix("xcworkspace")
    }
    func getProjects(from document: XCDocumentable) -> [XCProject] {
        if let workspace = document as? XCWorkspace, let projects = workspace.projects {
            return projects
        }else if let project = document as? XCProject {
            return [project]
        }
        return []
    }
}
