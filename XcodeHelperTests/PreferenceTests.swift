//
//  PreferenceTests.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 6/4/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import XCTest
import XcodeHelperKit
@testable import XcodeHelper

class PreferenceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testStringValue() {
        
        let logging = Preference.logging.stringValue
        print(logging)
    }

}
