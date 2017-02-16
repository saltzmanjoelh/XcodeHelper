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
//    func testGetObjects(){
//        let project = XCProject(at: XCProjectTests.projectOnePath)
//        let contents = project.getPbxProjectContents(at: project.pbxProjectPath);
//        
//        let result = project.getObjects(from: contents!)
//        
//        XCTAssertNotNil(result)
//    }

    func testGetXcSchemeManagement(){
        let project = XCProject(at: XCProjectTests.projectOnePath)
        let xcSchemesUrl = project.getXcSchemesUrl(for: project.getCurrentUser()!, at: project.path)
        
        let result = project.getXcSchemeManagement(from: xcSchemesUrl!.appendingPathComponent(project.managementPlistName))
        
        XCTAssertNotNil(result)
        XCTAssertNotNil(result!["SchemeUserState"])
    }
//    func testGetXcSchemeFiles(){
//        let project = XCProject(at: XCProjectTests.projectOnePath)
//        let url = project.getXcSchemesUrl(for: project.getCurrentUser()!, at: project.path)
//        
//        let result = project.getXcSchemeFiles(at: url!.path)
//        
//        XCTAssertNotNil(result)
//    }
    
    func testGetTargetType(){
        let project = XCProject(at: XCProjectTests.projectOnePath)
        let xcSchemesUrl = project.getXcSchemesUrl(for: project.getCurrentUser()!, at: project.path)
        let xcSchemeManagement = project.getXcSchemeManagement(from: xcSchemesUrl!.appendingPathComponent(project.managementPlistName))
        let schemes = xcSchemeManagement?["SchemeUserState"] as? NSDictionary
        
        let result = project.getTargetType(for: schemes?.allKeys.first as! String, at: xcSchemesUrl!)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, XcodeHelper.XCTarget.TargetType.binary)
    }
    func testTargetTypes(){
        let project = XCProject(at: XCProjectTests.projectTwoPath)
        let xcSchemesUrl = project.getXcSchemesUrl(for: project.getCurrentUser()!, at: project.path)
        let xcSchemeManagement = project.getXcSchemeManagement(from: xcSchemesUrl!.appendingPathComponent(project.managementPlistName))
        let schemes = xcSchemeManagement?["SchemeUserState"] as? NSDictionary
        
        let result = schemes!.allKeys.flatMap{ project.getTargetType(for: $0 as! String, at: xcSchemesUrl!) }
        
        XCTAssertEqual(result.filter({ $0 == .unknown }).count, 0)
        XCTAssertEqual(result.count, XCProjectTests.projectTwoTargetCount)
        XCTAssertEqual(Set(result).count, 15, "There should have been one of each TargetType")
    }
    func testTargetNames() {
        let project = XCProject(at: XCProjectTests.projectOnePath)
        
        let result = project.orderedTargets()
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result![0].name, "ProjectOne")
        XCTAssertEqual(result![1].name, "TargetB")
    }
    func testCurrentTargetName() {
        let project = XCProject(at: XCProjectTests.projectOnePath)
        
        let result = project.currentTargetName()
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "ProjectOne")
    }
}
