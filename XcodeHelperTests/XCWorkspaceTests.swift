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
    
    func testGetCurrentUser() {
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath)
        
        let result = workspace.getCurrentUser()
        
        XCTAssertEqual(result, "joelsaltzman")
    }
    func testgetXcUserStateUrl(){
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath)
        let user = workspace.getCurrentUser()
        
        let result = workspace.getXcUserStateUrl(for: user!, at: workspace.path)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.path.hasSuffix("UserInterfaceState.xcuserstate"))
    }
    func testXcUserStateContents(){
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath)
        let user = workspace.getCurrentUser()
        let userStateUrl = workspace.getXcUserStateUrl(for: user!, at: workspace.path)
        
        let result = workspace.getXCUserStateContents(at: userStateUrl!)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.isKind(of: NSDictionary.self))
        XCTAssertNotNil(result!["$objects"])
    }
    func testGetProjects() {
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath)
        
        let result = workspace.getProjects(from: workspace.path)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.count == 2)
        XCTAssertTrue(type(of: result!.first!) == XCProject.self)
    }
    
    func testTargetNames() {
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath)
        
        let result = workspace.orderedTargets()
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, XCWorkspaceTests.projectOneTargetCount+XCWorkspaceTests.projectTwoTargetCount)
        XCTAssertEqual(result![0].name, "ProjectOne")
        XCTAssertEqual(result![1].name, "ProjectTwo")
        XCTAssertEqual(result![2].name, "TargetB")
        XCTAssertEqual(result![3].name, "TargetB")
    }
    func testCurrentTargetName() {
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath)

        let result = workspace.currentTargetName()
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, "MessagesExtension")
    }
}
