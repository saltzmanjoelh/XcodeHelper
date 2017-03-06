//
//  XCProjectTests.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/30/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import XCTest
@testable import XcodeHelper

class XCProjectTests: XcodeHelperTestCase {

    func testGetXcSchemeManagement(){
        let xcSchemesUrl = projectOne.getUserXcSchemesURL(projectOne.currentUser!, at: projectOne.path)
        
        let result = projectOne.getXcSchemeManagement(from: xcSchemesUrl!.appendingPathComponent(projectOne.managementPlistName))
        
        XCTAssertNotNil(result)
        XCTAssertNotNil(result!["SchemeUserState"])
    }
    func testSchemeManagementModificationDate(){
        let now = NSDate()
        
        let result = projectOne.schemeManagementModificationDate()
        
        XCTAssertNotNil(result)
        //repo was just cloned so modification date should be recent
        XCTAssertTrue(now.timeIntervalSince1970 - result!.timeIntervalSince1970 < 30)
    }
    func testXcSharedSchemesUrl(){
        
        let url = projectTwo.getSharedXcSchemesURL(at: projectTwo.path)
        
        XCTAssertNotNil(url)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url!.path))
    }
    func testXcUserSchemesUrl(){
        
        let url = projectTwo.getUserXcSchemesURL(projectTwo.currentUser!, at: projectTwo.path)
        
        XCTAssertNotNil(url)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url!.path))
    }
//    func testGetXcSchemeFiles(){
//        let project = XCProject(at: XCProjectTests.projectOnePath)
//        let url = project.getXcSchemesUrl(for: project.getCurrentUser()!, at: project.path)
//        
//        let result = project.getXcSchemeFiles(at: url!.path)
//        
//        XCTAssertNotNil(result)
//    }
    
    func testGetUserTargetType(){
        let xcSchemesUrl = projectOne.getUserXcSchemesURL(projectOne.currentUser!, at: projectOne.path)
        let xcSchemeManagement = projectOne.getXcSchemeManagement(from: xcSchemesUrl!.appendingPathComponent(projectOne.managementPlistName))
        let schemes = xcSchemeManagement?["SchemeUserState"] as? NSDictionary
        
        let result = projectOne.getTargetType(for: schemes?.allKeys.first as! String, from: [xcSchemesUrl!])
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, XcodeHelper.XCTarget.TargetType.binary)
    }
    func testGetSharedTargetType(){
        let userXcSchemesUrl = projectTwo.getUserXcSchemesURL(projectTwo.currentUser!, at: projectTwo.path)
        let sharedXcSchemesUrl = projectTwo.getSharedXcSchemesURL(at: projectTwo.path)
        let xcSchemeManagement = projectTwo.getXcSchemeManagement(from: userXcSchemesUrl!.appendingPathComponent(projectTwo.managementPlistName))
        let schemes = xcSchemeManagement?["SchemeUserState"] as? NSDictionary
        let key = schemes!.allKeys.filter{($0 as! String).contains("_^#shared#^_")}.first as! String

        let result = projectTwo.getTargetType(for: key, from: [userXcSchemesUrl!, sharedXcSchemesUrl!])
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, XcodeHelper.XCTarget.TargetType.binary)
    }
    func testTargetTypes(){
        let xcSharedSchemesUrl = projectTwo.getSharedXcSchemesURL(at: projectTwo.path)
        let xcUserSchemesUrl = projectTwo.getUserXcSchemesURL(projectTwo.currentUser!, at: projectTwo.path)
        let xcSchemeManagement = projectTwo.getXcSchemeManagement(from: xcUserSchemesUrl!.appendingPathComponent(projectTwo.managementPlistName))
        let schemes = xcSchemeManagement?["SchemeUserState"] as? NSDictionary
        let expected: Set<XCTarget.TargetType>= Set([.app, .binary, .framework, .appExtension, .bundle, .xpc, .appleScriptAction, .kernelExtension, .staticLib, .metalLib, .prefPane, .plugin, .screenSaver, .spotlightImporter, .quartzPlugin])
        
        
        let result = schemes!.allKeys.flatMap{ projectTwo.getTargetType(for: $0 as! String, from: [xcUserSchemesUrl!, xcSharedSchemesUrl!]) }
        
        XCTAssertEqual(result.filter({ $0 == .unknown }).count, 0)
        XCTAssertEqual(result.count, XCProjectTests.projectTwoTargetCount)
        XCTAssertEqual(Set(result).count, expected.count, "There should have been one of each TargetType. Missing: \(expected.subtracting(Set(result)))")
    }
    func testOrderedTargets() {
        
        let result = projectTwo.orderedTargets()
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result[0].orderHint, 1)
        XCTAssertEqual(result[0].name, "ProjectTwo")
        XCTAssertEqual(result[1].name, "TargetB")
    }
    func testGetOrderedTargets_failure() {
        let project = XCProject(at: XCProjectTests.projectOnePath)
        
        let result = project.getOrderedTargets(at: "", from: [URL(fileURLWithPath:"")], with: [URL(fileURLWithPath:"")])
        
        XCTAssertNil(result)
    }
    
    func testCurrentTargetName() {
        let project = XCProject(at: XCProjectTests.projectOnePath, currentUser: XcodeHelperTestCase.currentUser)
        
        let result = project.currentTargetName()
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "ProjectOne")
    }
    func testCurrentTargetName_failure() {
        let project = XCProject(at: XCProjectTests.projectOnePath)
        
        let result = project.currentTargetName()
        
        XCTAssertNil(result)
    }
    
    func testContentsOfDirectory() {
        let path = XCProjectTests.projectOnePath
        
        let result = FileManager.default.recursiveContents(of: URL(fileURLWithPath: path))
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, 12)
    }
//    func testGetOrderHints() {
//        let project = XCProject(at: XCProjectTests.projectOnePath, currentUser: currentUser)
//        let urls = project.getXcSchemeManagementURLs(at: project.path)!
//        
//        let result = project.getOrderHints(from: urls)
//        
//        XCTAssertNotNil(result)
//        print("hints: \(result)")
//    }
    func testGetTargetNames() {
        
        let result = projectOne.getTargetNames(at: projectOne.path)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, ["ProjectOne.xcscheme", "TargetB.xcscheme"])
    }
    func testGetTargetTypes() {
        let targetNames = projectTwo.getTargetNames(at: projectTwo.path)!
        
        let result = projectTwo.getTargetTypes(for: targetNames, from: projectTwo.getXcSchemeURLs(XcodeHelperTestCase.currentUser, at: projectTwo.path)! )
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!["SpotlightImport.xcscheme"], XcodeHelper.XCTarget.TargetType.spotlightImporter)
    }
    func testGetTargetType_nilReturn() {

        let result = projectTwo.getTargetType(for: "invalid", from: [URL(fileURLWithPath: "invalid")])
        
        XCTAssertNil(result)
    }
    func testGetXcSchemeManagementURLs() {
        
        let result = projectTwo.getXcSchemeManagementURLs(at: projectTwo.path)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, 1)
    }
    func testGetOrderHints() {
        
        let result = projectTwo.getOrderHints(from: projectTwo.getXcSchemeManagementURLs(at: projectTwo.path)!)
        
        XCTAssertEqual(result.count, XcodeHelperTestCase.projectTwoTargetCount)
        XCTAssertEqual(result["ProjectTwo.xcscheme"], 1)
        XCTAssertEqual(result["TargetB.xcscheme"], 3)
    }
    func testDefaultImagePath() {
        
        let result =  projectOne.imagePath
        
        XCTAssertFalse(result == "")
    }
    func testGetXcSchemeURLs_nilReturn() {
        
        let result = projectOne.getXcSchemeURLs("invalid", at: "///invalid")
        
        XCTAssertNil(result)
    }
    func testGetTargetNames_noContents() {
        
        let result = projectOne.getTargetNames(at: "///invalid")
        
        XCTAssertNil(result)
    }
    func testGetTargetNames_noTargets() {
        //rename xcscheme files for test, restore when done
        let targetFiles = FileManager.default.recursiveContents(of: URL(fileURLWithPath: projectOne.path))!.filter({ $0.pathExtension == "xcscheme" })
        targetFiles.forEach{ try! FileManager.default.moveItem(at: $0, to: $0.appendingPathExtension("backup") ) }
        defer { targetFiles.forEach{ try! FileManager.default.moveItem(at: $0.appendingPathExtension("backup"), to: $0 ) } }
        
        let result = projectOne.getTargetNames(at: "///invalid")

        XCTAssertNil(result)
    }
    func testParseTargetTypeFromXcSchemeFile_error() {
        
        let result = projectOne.parseTargetTypeFromXcSchemeFile(at: "invalid")
        
        XCTAssertNil(result)
    }
    func testGetXcSchemeManagementURLs_emptyContents() {
        
        let result = projectOne.getXcSchemeManagementURLs(at: "invalid")
        
        XCTAssertNil(result)
    }
    func testGetXcSchemeManagementURLs_missingPlist() {
        
        let result = projectOne.getXcSchemeManagementURLs(at: "invalid")
        
        XCTAssertNil(result)
    }
}
