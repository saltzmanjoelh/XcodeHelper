//
//  XcodeHelperTests.swift
//  XcodeHelperTests
//
//  Created by Joel Saltzman on 10/30/16.
//  Copyright © 2016 Joel Saltzman. All rights reserved.
//

import XCTest
import ProcessRunner
@testable import XcodeHelper

class XcodeHelperTestCase: XCTestCase {
    
    //xcworkspace for use with testing
    static let workspaceRepoURL = "https://github.com/saltzmanjoelh/HelloWorkspace"
    static let workspaceFilename: String = "Workspace.xcworkspace"
    static var workspacePath: String = {
        return copiedWorkspace(atPath: workspaceOriginalPath)
    }()
    static var projectOnePath: String {
        return copiedProject(atPath: projectOneOriginalPath)
    }
    static var projectTwoPath: String {
        return copiedProject(atPath: projectTwoOriginalPath)
    }
    
    
    static var projectOneTargetCount = 2
    static var projectTwoTargetCount = 37
    static var currentUser = XCProject.getCurrentUser()!
    lazy var workspace: XCWorkspace = {
        return XCWorkspace(at: XcodeHelperTestCase.workspacePath, currentUser: XcodeHelperTestCase.currentUser)
    }()
    lazy var projectOne: XCProject = {
        return XCProject(at: XcodeHelperTestCase.projectOnePath, currentUser: XcodeHelperTestCase.currentUser)
    }()
    lazy var projectTwo: XCProject = {
        return XCProject(at: XcodeHelperTestCase.projectTwoPath, currentUser: XcodeHelperTestCase.currentUser)
    }()
    
    static var workspaceOriginalPath: String = {
        guard let tempDirectoryPath = XcodeHelperTestCase.cloneToTempDirectory(repoURL: workspaceRepoURL) else {
            XCTFail("Failed to clone workspace repo")
            return ""
        }
        return URL(fileURLWithPath: tempDirectoryPath).appendingPathComponent(XCWorkspaceTests.workspaceFilename).path
    }()
    static var projectOneOriginalPath: String = {
        guard let tempDirectoryPath = XcodeHelperTestCase.cloneToTempDirectory(repoURL: workspaceRepoURL) else {
            XCTFail("Failed to clone workspace repo")
            return ""
        }
        return URL(fileURLWithPath: tempDirectoryPath).appendingPathComponent("ProjectOne/ProjectOne.xcodeproj").path
    }()
    static var projectTwoOriginalPath: String = {
        guard let tempDirectoryPath = XcodeHelperTestCase.cloneToTempDirectory(repoURL: workspaceRepoURL) else {
            XCTFail("Failed to clone workspace repo")
            return ""
        }
        return URL(fileURLWithPath: tempDirectoryPath).appendingPathComponent("ProjectTwo/ProjectTwo.xcodeproj").path
    }()
    
    static func copiedProject(atPath path: String) -> String {
        let projectURL = URL.init(fileURLWithPath: path)
        let baseURL = projectURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let copyPath = baseURL
            .deletingLastPathComponent()
            .appendingPathComponent("TestingProject")
        if FileManager.default.fileExists(atPath: copyPath.path) {
            _ = try? FileManager.default.removeItem(atPath: copyPath.path)
        }
        _ = try? FileManager.default.copyItem(atPath: baseURL.path, toPath: copyPath.path)
        return path.replacingOccurrences(of: baseURL.path, with: copyPath.path)
    }
    static func copiedWorkspace(atPath path: String) -> String {
        let projectURL = URL.init(fileURLWithPath: path)
        let baseURL = projectURL
            .deletingLastPathComponent()
        let copyPath = baseURL
            .deletingLastPathComponent()
            .appendingPathComponent("TestingWorkspace")
        if FileManager.default.fileExists(atPath: copyPath.path) {
            _ = try? FileManager.default.removeItem(atPath: copyPath.path)
        }
        _ = try? FileManager.default.copyItem(atPath: baseURL.path, toPath: copyPath.path)
        return path.replacingOccurrences(of: baseURL.path, with: copyPath.path)
    }
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    static func cloneToTempDirectory(repoURL: String) -> String? {
        let tempDir = "/tmp/\(UUID())"
        if !FileManager.default.fileExists(atPath: tempDir) {
            do {
                try FileManager.default.createDirectory(atPath: tempDir, withIntermediateDirectories: false, attributes: nil)
            }catch _{
                
            }
        }
        let cloneResult = ProcessRunner.synchronousRun("/usr/bin/env", arguments: ["git", "clone", repoURL, tempDir], printOutput: true)
        XCTAssert(cloneResult.exitCode == 0, "Failed to clone repo: \(String(describing: cloneResult.error))")
        XCTAssert(FileManager.default.fileExists(atPath: tempDir))
        print("done cloning temp dir: \(tempDir)")
        return tempDir
    }
}
