//
//  TargetSettingsViewController.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/21/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import AppKit


class TargetSettingsViewController: NSViewController {
    
    var project: XCProject?
    
    enum SubviewIdentifier: String {
        case updatePackagesMacOS = "Update Packages - macOS"
        case updatePackagesDocker = "Update Packages - Docker"
        case buildInDocker = "Build in Docker"
        case createArchive = "Create Archive"
        case createXCArchive = "Create XCArchive"
        case uploadArchive = "Upload Archive"
        case gitTag = "Git Tag"
        static func allIdentifiers() -> [SubviewIdentifier] {
            return [.updatePackagesMacOS, .updatePackagesDocker, .buildInDocker, .createArchive, .createXCArchive, .uploadArchive, .gitTag]
        }
    }
    let data: [Any] = [SubviewIdentifier.updatePackagesMacOS, SubviewIdentifier.updatePackagesMacOS.rawValue,
                       SubviewIdentifier.updatePackagesDocker, SubviewIdentifier.updatePackagesDocker.rawValue,
                       SubviewIdentifier.buildInDocker, SubviewIdentifier.buildInDocker.rawValue,
                       SubviewIdentifier.createArchive, SubviewIdentifier.createArchive.rawValue,
                       SubviewIdentifier.createXCArchive, SubviewIdentifier.createXCArchive.rawValue,
                       SubviewIdentifier.uploadArchive, SubviewIdentifier.uploadArchive.rawValue,
                       SubviewIdentifier.gitTag, SubviewIdentifier.gitTag.rawValue]
    var viewControllers = [String:CommandSettingsViewController]()
    let defaultHeights: [CGFloat] = [34.0, 22.0, 71.0, 14.0, 14.0, 98.0, 44.0]
    
    @IBOutlet var tableView: NSTableView?
    override func viewDidLoad() {
        tableView?.reloadData()
    }
}

extension TargetSettingsViewController: NSTableViewDataSource, NSTableViewDelegate {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return data[safe: row];
    }
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let dataItem = data[safe: row] else { return nil }
        if let identifier = dataItem as? SubviewIdentifier {
            //group row
            guard let view = tableView.make(withIdentifier: "HeaderCell", owner: self) as? NSTableCellView else { return nil }
            view.textField?.stringValue = identifier.rawValue
            return view
        }
        
        //settings row
        guard let identifierString = dataItem as? String else { return nil }
        if let viewController = viewControllers[identifierString] {
            return viewController.view
        }
        guard let viewController = storyboard?.instantiateController(withIdentifier: dataItem as! String) as? NSViewController else { return nil }
        return viewController.view
    }
    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row%2 == 0 {
            return 24.0
        }
        guard let item = data[safe: row] as? String,
              let viewController = viewControllers[item] else { return defaultHeights[row/2] }
        return viewController.view.bounds.size.height
    }
}
