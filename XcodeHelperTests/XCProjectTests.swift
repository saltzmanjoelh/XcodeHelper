//
//  XCProjectTests.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/30/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import XCTest
import SynchronousProcess
@testable import XcodeHelper

class XCProjectTests: XCTestCase {
    
    static let workspaceRepoURL = "https://github.com/saltzmanjoelh/HelloWorkspace"
    static var projectPath: String = {
        guard let tempDirectoryPath = XCProjectTests.cloneToTempDirectory(repoURL: workspaceRepoURL) else {
            XCTFail("Failed to clone workspace repo")
            return ""
        }
        return URL(fileURLWithPath: tempDirectoryPath).appendingPathComponent("ProjectOne/ProjectOne.xcodeproj").path
    }()
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
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetObjects(){
        let project = XCProject(at: XCProjectTests.projectPath)
        let contents = project.getPbxProjectContents(at: project.pbxProjectPath);
        
        let result = project.getObjects(from: contents!)
        
        XCTAssertNotNil(result)
    }
    func testTargetNames() {
        let project = XCProject(at: XCProjectTests.projectPath)
        let contents = project.getPbxProjectContents(at: project.pbxProjectPath);
        
        let result = project.getTargetNames(from: contents!)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.contains("ProjectOne"))
        XCTAssertTrue(result!.contains("TargetB"))
    }
}
