//
//  TargetSettingsViewController.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/21/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import AppKit
import XcodeHelperKit

class TargetSettingsViewController: NSViewController {
    
    var project: XCProject?
    
    let data: [String] = [Command.updateMacOSPackages.title, Command.updateMacOSPackages.rawValue,
                       Command.updateDockerPackages.title, Command.updateDockerPackages.rawValue,
                       Command.dockerBuild.title, Command.dockerBuild.rawValue,
                       Command.createArchive.title, Command.createArchive.rawValue,
                       Command.createXcarchive.title, Command.createXcarchive.rawValue,
                       Command.uploadArchive.title, Command.uploadArchive.rawValue,
                       Command.gitTag.title, Command.gitTag.rawValue,
                       "General", "General"]
    var viewControllers = [String:CommandSettingsViewController]()
    let defaultHeights: [CGFloat] = [34.0, //Update Packages - macOS
                                     56.0, //Update Packages - Docker
                                     150.0, //Build in Docker
                                     14.0, //Create Archive
                                     14.0, //Create XCArchive
                                     98.0, //Upload Archive
                                     44.0, //Git tag
                                     44.0] //General
    
    @IBOutlet var tableView: NSTableView?
    override func viewDidLoad() {
        tableView?.reloadData()
    }
}
class TrackingTableView: NSTableView {
    var trackingArea: NSTrackingArea?
    
    override func awakeFromNib() {
//        updateTrackingAreas()
    }
    override func updateTrackingAreas() {
//        super.updateTrackingAreas()
//        if let ta = trackingArea {
//            removeTrackingArea(ta)
//        }
//        trackingArea = NSTrackingArea.init(rect: bounds, options: [.mouseMoved, .activeInKeyWindow], owner: self, userInfo: nil)
//        addTrackingArea(trackingArea!)
    }
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        let location =  convert(event.locationInWindow, from: nil)
//        location.y = frame.size.height - location.y;
        let mouseRow = row(at: location)
        if let theDelegate = delegate,
            let shouldSelect = theDelegate.tableView(_:shouldSelectRow:),
            shouldSelect(self, mouseRow) {
            selectRowIndexes(IndexSet.init(integer: mouseRow), byExtendingSelection: false)
            window?.becomeFirstResponder()
        }
    }
}
class TableRowView: NSTableRowView {
    override func drawSelection(in dirtyRect: NSRect) {

    }
}
extension TargetSettingsViewController: NSTableViewDataSource, NSTableViewDelegate {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let tableRow = TableRowView()
        return tableRow
    }
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return data[safe: row];
    }
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let dataItem = data[safe: row] else { return nil }
        if row % 2 == 0 {
            //group row
            let identifier = dataItem
            guard let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as? NSTableCellView else { return nil }
            view.textField?.stringValue = identifier
            return view
        }
        
        //settings row
        let identifierString = dataItem
        if let viewController = viewControllers[identifierString] {
            return viewController.view
        }
        guard let viewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: identifierString)) as? NSViewController else { return nil }
        return viewController.view
    }
//    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
//        return false
//    }
    public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row%2 == 0 {
            return 24.0
        }
        guard let item = data[safe: row],
              let viewController = viewControllers[item] else { return defaultHeights[row/2] }
        return viewController.view.bounds.size.height
    }
    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return row % 2 != 0
    }
}
