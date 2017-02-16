//
//  TargetListControllerTests.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 2/5/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation
import XCTest
import SynchronousProcess
@testable import XcodeHelper

class TargetListControllerTests: XcodeHelperTestCase {
    
    var controller = TargetListController()
    
    //TODO: fix this, it checks XcodeHelper on launch
    func testNumberOfRowsInTableView() {
        let workspace = XCWorkspace(at: XCWorkspaceTests.workspacePath)
        controller.xcode = Xcode()
        controller.xcode.currentDocument = workspace
        controller.prepareSourceObjects()
        
        let result = controller.numberOfRows(in: NSTableView())
        
//        XCTAssertNotNil(result)
//        XCTAssertEqual(result, 42)
    }
    
}
