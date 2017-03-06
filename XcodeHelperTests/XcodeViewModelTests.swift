//
//  XcodeViewModelTests.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 2/28/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import XCTest
@testable import XcodeHelper

class XcodeViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitWithEmptyProjects() {
        
        let result = XcodeViewModel(xcode: Xcode(), document: nil)
        
        XCTAssertEqual(result.projects.count, 0)
    }
}
