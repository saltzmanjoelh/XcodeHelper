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

class XCWorkspaceTests: XCTestCase {
    
    //xcworkspace for use with testing
    static let workspaceRepoURL = "https://github.com/saltzmanjoelh/HelloWorkspace"
    static let workspaceFilename: String = "Workspace.xcworkspace"
    static var workspacePath: String = {
        guard let tempDirectoryPath = XCWorkspaceTests.cloneToTempDirectory(repoURL: workspaceRepoURL) else {
            XCTFail("Failed to clone workspace repo")
            return ""
        }
        return URL(fileURLWithPath: tempDirectoryPath).appendingPathComponent(XCWorkspaceTests.workspaceFilename).path
    }()
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    private static func cloneToTempDirectory(repoURL:String) -> String? {
        let tempDir = "/tmp/\(UUID())"
        if !FileManager.default.fileExists(atPath: tempDir) {
            do {
                try FileManager.default.createDirectory(atPath: tempDir, withIntermediateDirectories: false, attributes: nil)
            }catch _{
                
            }
        }
        let cloneResult = Process.run("/usr/bin/env", arguments: ["git", "clone", repoURL, tempDir], printOutput: true)
        XCTAssert(cloneResult.exitCode == 0, "Failed to clone repo: \(cloneResult.error)")
        XCTAssert(FileManager.default.fileExists(atPath: tempDir))
        print("done cloning temp dir: \(tempDir)")
        return tempDir
    }
    
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
    func testCurrentTargetName() {
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath)
        let user = workspace.getCurrentUser()
        let stateUrl = workspace.getXcUserStateUrl(for: user!, at: workspace.path)
        let contents = workspace.getXCUserStateContents(at: stateUrl!)
        
        let result = workspace.getCurrentTargetName(from: contents!)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, "TargetB")
    }
}
