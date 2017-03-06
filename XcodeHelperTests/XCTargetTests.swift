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
        self.continueAfterFailure = false
    }

    func testImage() {
        let project = XCProject(at: "")

        let result = XCTarget.TargetType.allValues().flatMap{ XCTarget(name: "", orderHint: 0, targetType: $0, project: project).imageData() }
        
        XCTAssertEqual(result.count, XCTarget.TargetType.allValues().count)
        XCTAssertEqual(Set(result).count, 8, "There should have been 8 different images")
    }
    func testUnknownTargetType() {
        let fileExtension = UUID().uuidString
        
        let result = XCTarget.TargetType.init(from: fileExtension)
        
        XCTAssertEqual(result, XCTarget.TargetType.unknown)
    }
    func testImagePath() {
        let project = XCProject(at: "")
        let target = XCTarget(name: "", orderHint: 0, targetType: .app, project: project)
        
        let result = target.imagePath
        
        XCTAssertEqual(result, "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Mac/Application/Cocoa Application.xctemplate/TemplateIcon.icns")
    }
    func testEquality() {
        let project = XCProject(at: "")
        let targetOne = XCTarget(name: UUID().uuidString, orderHint: 0, targetType: .app, project: project)
        let targetTwo = XCTarget(name: targetOne.name, orderHint: 0, targetType: .app, project: project)
        
        let result = targetOne == targetTwo
        
        XCTAssertTrue(result)
    }
}
