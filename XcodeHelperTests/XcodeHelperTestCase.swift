//
//  XcodeHelperTests.swift
//  XcodeHelperTests
//
//  Created by Joel Saltzman on 10/30/16.
//  Copyright © 2016 Joel Saltzman. All rights reserved.
//

import XCTest
@testable import XcodeHelper

class XcodeHelperTestCase: XCTestCase {
    
    //xcworkspace for use with testing
    static let workspaceRepoURL = "https://github.com/saltzmanjoelh/HelloWorkspace"
    static let workspaceFilename: String = "Workspace.xcworkspace"
    static var workspacePath: String = {
        guard let tempDirectoryPath = XcodeHelperTestCase.cloneToTempDirectory(repoURL: workspaceRepoURL) else {
            XCTFail("Failed to clone workspace repo")
            return ""
        }
        return URL(fileURLWithPath: tempDirectoryPath).appendingPathComponent(XCWorkspaceTests.workspaceFilename).path
    }()
    static var projectOnePath: String = {
        guard let tempDirectoryPath = XcodeHelperTestCase.cloneToTempDirectory(repoURL: workspaceRepoURL) else {
            XCTFail("Failed to clone workspace repo")
            return ""
        }
        return URL(fileURLWithPath: tempDirectoryPath).appendingPathComponent("ProjectOne/ProjectOne.xcodeproj").path
    }()
    static var projectTwoPath: String = {
        guard let tempDirectoryPath = XcodeHelperTestCase.cloneToTempDirectory(repoURL: workspaceRepoURL) else {
            XCTFail("Failed to clone workspace repo")
            return ""
        }
        return URL(fileURLWithPath: tempDirectoryPath).appendingPathComponent("ProjectTwo/ProjectTwo.xcodeproj").path
    }()
    static var projectOneTargetCount = 2
    static var projectTwoTargetCount = 40
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    static func cloneToTempDirectory(repoURL:String) -> String? {
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
}
