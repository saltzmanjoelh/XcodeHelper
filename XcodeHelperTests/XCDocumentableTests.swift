//
//  XCDocumentableTests.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 3/5/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import XCTest
@testable import XcodeHelper

class XCDocumentableTests: XcodeHelperTestCase {

    func testGetXCUserStateContents_fileDoesNotExist() {
        let document = self.projectOne
        
        let result = document.getXcUserStateContents(at: URL(fileURLWithPath: "invalid"))
        
        XCTAssertNil(result)
    }
    func testGetXCUserStateContents() {
        let document = self.projectOne
        let url = document.getXcUserStateUrl(for: XcodeHelperTestCase.currentUser, at: document.path)
        
        let result = document.getXcUserStateContents(at: url!)
        
        XCTAssertNotNil(result)
    }
    func testGetCurrentTargetName_missingObjects() {
        let document = self.projectOne
        
        let result = document.getCurrentTargetName(from: [:])
        
        XCTAssertNil(result)
    }
    func testGetCurrentTargetName_missingIDENameString() {
        let document = self.projectOne
        
        let result = document.getCurrentTargetName(from: ["$objects":[""]])
        
        XCTAssertNil(result)
    }
    func testGetCurrentTargetName() {
        let expected = "CurrentTarget"
        let document = self.projectOne
        
        let result = document.getCurrentTargetName(from: ["$objects": ["IDENameString", expected]])
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, expected)
    }
}
