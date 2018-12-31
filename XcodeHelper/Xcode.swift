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
import XcodeHelperKit

public protocol XCItem: CustomStringConvertible {
    var imagePath: String { get }
}

public class Xcode {
    public static let DocumentChanged: NSNotification.Name = NSNotification.Name(rawValue: "DocumentChanged")
    public let currentDocumentScript: NSAppleScript
    public let currentUser: String = XCWorkspace.getCurrentUser()!
    
    public init() {
        currentDocumentScript = NSAppleScript(source: """
        on appIsRunning(appName)
            tell application "System Events" to (name of processes) contains appName
        end appIsRunning
        if appIsRunning("Xcode") then
            tell application "Xcode"
                if count of documents > 0 then
                    get path of first document
                    -- get active workspace document
                end if
            end tell
        end if


        """)!
    }

    public func getCurrentDocumentPath(using script: NSAppleScript) -> String? {
        var error: NSDictionary?
        let output: NSAppleEventDescriptor = script.executeAndReturnError(&error)
        if (error != nil) {
            print("error: \(String(describing: error))")
            return nil
        }
        return output.stringValue
    }
    public func getCurrentDocumentable(using script: NSAppleScript) -> XCDocumentable? {
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
    public func getProjects(from document: XCDocumentable) -> [XCProject] {
        if let workspace = document as? XCWorkspace, let projects = workspace.projects {
            return projects
        }else if let project = document as? XCProject {
            return [project]
        }
        return []
    }
}
