//
//  XCProjectTests.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/30/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import XCTest
import XcodeHelperKit
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
        XCTAssertTrue(now.timeIntervalSince1970 - result!.timeIntervalSince1970 < 30, "Modification date (\(result!.timeIntervalSince1970)) should have been within 30 seconds of now (\(now.timeIntervalSince1970)). Difference: \(now.timeIntervalSince1970 - result!.timeIntervalSince1970)")
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
        XCTAssertEqual(result!, XCTarget.TargetType.binary)
    }
    func testGetSharedTargetType(){
        let userXcSchemesUrl = projectTwo.getUserXcSchemesURL(projectTwo.currentUser!, at: projectTwo.path)
        let sharedXcSchemesUrl = projectTwo.getSharedXcSchemesURL(at: projectTwo.path)
        let xcSchemeManagement = projectTwo.getXcSchemeManagement(from: userXcSchemesUrl!.appendingPathComponent(projectTwo.managementPlistName))
        let schemes = xcSchemeManagement?["SchemeUserState"] as? NSDictionary
        let key = schemes!.allKeys.filter{($0 as! String).contains("_^#shared#^_")}.first as! String

        let result = projectTwo.getTargetType(for: key, from: [userXcSchemesUrl!, sharedXcSchemesUrl!])
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, XCTarget.TargetType.binary)
    }
    func testTargetTypes(){
        let xcSharedSchemesUrl = projectTwo.getSharedXcSchemesURL(at: projectTwo.path)
        let xcUserSchemesUrl = projectTwo.getUserXcSchemesURL(projectTwo.currentUser!, at: projectTwo.path)
        let xcSchemeManagement = projectTwo.getXcSchemeManagement(from: xcUserSchemesUrl!.appendingPathComponent(projectTwo.managementPlistName))
        let schemes = xcSchemeManagement?["SchemeUserState"] as? NSDictionary
        let expected: Set<XCTarget.TargetType> = Set(XCTarget.TargetType.allValues())
        
        
        let result = schemes!.allKeys.compactMap{ projectTwo.getTargetType(for: $0 as! String, from: [xcUserSchemesUrl!, xcSharedSchemesUrl!]) }
        
        let unknownTypes = result.filter({ $0 == .unknown })
        XCTAssertEqual(unknownTypes.count, 0, "There shouldn't be any unknown types: \(unknownTypes)")
        XCTAssertEqual(result.count, XCProjectTests.projectTwoTargetCount)
        XCTAssertEqual(Set(result).count, expected.count-1, "There should have been one of each TargetType. Missing: \(expected.subtracting(Set(result)))")//don't count the unknown target type
    }
    func testOrderedTargets() {
        
        let result = projectTwo.orderedTargets()
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result.count > 0)
        XCTAssertEqual(result[0].orderHint, 1)
        XCTAssertEqual(result[0].name, "ProjectTwo")
        XCTAssertEqual(result[1].name, "TargetB")
    }
    func testGetOrderedTargets_failure() {
        let project = XCProject(at: XCProjectTests.projectOnePath)
        
        let result = project.getOrderedTargets(fromXcSchemesUrls: [URL(fileURLWithPath:"")], with: [URL(fileURLWithPath:"")])
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, 0)
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
        
        let result: [URL]? = FileManager.default.recursiveContents(of: URL(fileURLWithPath: path))
        
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
        
        let result = projectOne.getTargetNames()
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.contains("ProjectOne"))
        XCTAssertTrue(result!.contains("TargetB"))
    }
    func testGetTargetTypes() {
        let targetNames = projectTwo.getTargetNames()!
        
        let result = projectTwo.getTargetTypes(for: targetNames, from: projectTwo.getXcSchemeURLs(XcodeHelperTestCase.currentUser, at: projectTwo.path)! )
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.count > 0, "No target types were found")
        XCTAssertEqual(result!["Application"], XCTarget.TargetType.app)
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
        let urls = projectOne.getXcSchemeManagementURLs(at: projectOne.path)
        
        let result = projectOne.getOrderHints(from: urls!)
        
        XCTAssertEqual(result.count, XcodeHelperTestCase.projectOneTargetCount)
        XCTAssertEqual(result["ProjectOne.xcscheme"], 0)
        XCTAssertEqual(result["TargetB.xcscheme"], 2)
    }
    func testDefaultImagePath() {
        
        let result =  projectOne.imagePath
        
        XCTAssertFalse(result == "")
    }
    func testGetXcSchemeURLs_nilReturn() {
        
        let result = projectOne.getXcSchemeURLs("invalid", at: "///invalid")
        
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
