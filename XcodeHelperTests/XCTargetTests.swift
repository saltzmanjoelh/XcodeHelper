//
//  XCTargetTests.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 2/15/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import XCTest
@testable import XcodeHelper

extension XCTarget.TargetType {
    static func allValues() -> [XCTarget.TargetType] {
        return [.app, .binary, .framework, .appExtension, .bundle, .xpc, .appleScriptAction, .kernelExtension, .staticLib, .metalLib, .prefPane, .plugin, .screenSaver, .spotlightImporter, .quartzPlugin, .unknown]
    }
}

class XCTargetTests: XcodeHelperTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testImage() {

        let result = XCTarget.TargetType.allValues().flatMap{ XCTarget(name: "", orderHint: 0, targetType: $0).imageData() }
        
        XCTAssertEqual(result.count, XCTarget.TargetType.allValues().count)
        XCTAssertEqual(Set(result).count, 8, "There should have been 8 different images")
    }
    func testUnknownTargetType() {
        let fileExtension = UUID().uuidString
        
        let result = XCTarget.TargetType.init(from: fileExtension)
        
        XCTAssertEqual(result, XCTarget.TargetType.unknown)
    }
}
