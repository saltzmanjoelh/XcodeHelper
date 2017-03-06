//
//  XcodeTests.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 3/5/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import XCTest
@testable import XcodeHelper

class XcodeTests: XcodeHelperTestCase {

    func testGetCurrentDocumentPath_failure() {
        let xcode = Xcode()
        
        let result = xcode.getCurrentDocumentPath(using: NSAppleScript(source: "exit 1")!)
        
        XCTAssertNil(result)
    }
    func testGetCurrentDocumentPath() {
        let xcode = Xcode()
        
        let result = xcode.getCurrentDocumentPath(using: xcode.currentDocumentScript)
        
        XCTAssertNotNil(result)
    }
    func testGetCurrentDocumentable_failure() {
        let xcode = Xcode()
        
        let result = xcode.getCurrentDocumentable(using: NSAppleScript(source: "exit 1")!)
        
        XCTAssertNil(result)
    }
    
    func testGetCurrentDocumentable_project() {
        let xcode = Xcode()
        
        let result = xcode.getCurrentDocumentable(using: NSAppleScript(source: "return \"\(XcodeHelperTestCase.projectTwoPath)\"")!)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result is XCProject)
    }
    func testGetCurrentDocumentable_workspace() {
        let xcode = Xcode()
        
        let result = xcode.getCurrentDocumentable(using: NSAppleScript(source: "return \"\(XcodeHelperTestCase.workspacePath)\"")!)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result is XCWorkspace)
    }
    func testGetProjects_workspace() {
        let xcode = Xcode()
        
        let result = xcode.getProjects(from: self.workspace)
        
        XCTAssertEqual(result.count, 2)
    }
    func testGetProjects_emptyWorkspace() {
        let xcode = Xcode()
        var workspace = self.workspace
        workspace.projects = nil
        
        let result = xcode.getProjects(from: workspace)
        
        XCTAssertEqual(result.count, 0)
    }
    func testGetProjects_project() {
        let xcode = Xcode()
        
        let result = xcode.getProjects(from: self.projectOne)
        
        XCTAssertEqual(result.count, 1)
    }
}
