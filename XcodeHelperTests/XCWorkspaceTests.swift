//
//  XCWorkspaceTests.swift
//  XCWorkspaceTests
//
//  Created by Joel Saltzman on 10/30/16.
//  Copyright © 2016 Joel Saltzman. All rights reserved.
//

import XCTest
import SynchronousProcess
@testable import XcodeHelper

class XCWorkspaceTests: XcodeHelperTestCase {
    
    var currentUser = XCWorkspace.getCurrentUser()!
    
    override func setUp() {
        self.continueAfterFailure = false
    }
    func testGetCurrentUser() {
        
        let result = XCWorkspace.getCurrentUser()
        
        XCTAssertNotNil(result)        
        XCTAssertEqual(result, "joelsaltzman")
    }
    func testgetXcUserStateUrl(){
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath, currentUser: currentUser)
        
        let result = workspace.getXcUserStateUrl(for: currentUser, at: workspace.path)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.path.hasSuffix("UserInterfaceState.xcuserstate"))
    }
    func testXcUserStateContents(){
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath, currentUser: currentUser)
        let userStateUrl = workspace.getXcUserStateUrl(for: currentUser, at: workspace.path)
        
        let result = workspace.getXcUserStateContents(at: userStateUrl!)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.isKind(of: NSDictionary.self))
        XCTAssertNotNil(result!["$objects"])
    }
    func testGetProjects() {
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath, currentUser: currentUser)
        
        let result = workspace.getProjects(from: workspace.path)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.count == 2)
        XCTAssertTrue(type(of: result!.first!) == XCProject.self)
    }
    func testGetProjects_invalidUser(){
        let workspace = XCWorkspace(at: "invalid")
        
        let result = workspace.getProjects(from: "invalid")
        
        XCTAssertNil(result)
    }
    func testGetProjects_exception(){
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath, currentUser: currentUser)
        
        let result = workspace.getProjects(from: "invalid")
        
        XCTAssertNil(result)
    }
    
    func testTargetNames() {
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath, currentUser: currentUser)
        
        let result = workspace.orderedTargets()
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, XCWorkspaceTests.projectOneTargetCount+XCWorkspaceTests.projectTwoTargetCount)
        XCTAssertEqual(result[0].name, "ProjectOne")
        XCTAssertEqual(result[1].name, "ProjectTwo")
        XCTAssertEqual(result[2].name, "TargetB")
        XCTAssertEqual(result[3].name, "TargetB")
    }
    func testOrderedTargets_emptyReturn() {
        let workspace = XCWorkspace(at: "invalid", currentUser: "invalid")
        
        let result = workspace.orderedTargets()
        
        XCTAssertEqual(result.count, 0)
    }
    func testCurrentTargetName() {
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath, currentUser: currentUser)

        let result = workspace.currentTargetName()
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, "TargetB")
    }
    func testCurrentTargetName_failure() {
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath)
        
        let result = workspace.currentTargetName()
        
        XCTAssertNil(result)
    }
    func testEquality() {
        let workspaceA = XCWorkspace(at: XCWorkspaceTests.workspacePath, currentUser: currentUser)
        let workspaceB = XCWorkspace(at: XCWorkspaceTests.workspacePath, currentUser: currentUser)
        
        let result = workspaceA == workspaceB
        
        XCTAssertTrue(result)
    }
    func testDescription() {
        let expected = "WorkspaceName"
        let workspace = XCWorkspace.init(at: "/some/path/\(expected).xcworkspace")
        
        let result = workspace.description
        
        XCTAssertEqual(result, expected)
    }
}
