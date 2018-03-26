//
//  TargetsViewController.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 10/30/16.
//  Copyright © 2016 Joel Saltzman. All rights reserved.
//

import Cocoa

class TargetsViewController: NSViewController {
    
    
    @IBOutlet var listController: TargetListController?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else {
            return
        }
        listController?.outlineView?.reloadItem(nil)
        listController?.outlineView?.expandItem(nil, expandChildren: true)
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
//            print("representedObject: \(representedObject)")
        }
    }

    @IBAction func activateExtension(_ sender: AnyObject) {
        
    }
    
}

