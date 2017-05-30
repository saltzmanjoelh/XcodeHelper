//
//  TargetListController.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 2/4/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import AppKit

class DataCell: NSTableCellView {
    static let identifier = "DataCell"
    var indentationLevel: CGFloat = 0 {
        didSet {
            self.constraints.filter{
                if let firstItem = $0.firstItem as? NSImageView, let secondItem = $0.secondItem as? DataCell {
                    return firstItem == imageView && secondItem == self && $0.firstAttribute == .leading
                }
                return false
            }.first?.constant = 10.0 * indentationLevel
        }
    }
}

class TargetListController: NSObject {
    
    @IBOutlet var outlineView: NSOutlineView?
    @IBOutlet var tableView: NSTableView?
    
    //this class gets created on app launch so we create this here instead of after app launch
    let xcodeViewModel: XcodeViewModel
    override init() {
        let xcode = Xcode()
        self.xcodeViewModel =  XcodeViewModel(xcode: xcode, document: xcode.getCurrentDocumentable(using: xcode.currentDocumentScript))
    }
}
class GroupRow: NSTableRowView {
    override func draw(_ dirtyRect: NSRect) {
        if isGroupRowStyle {
            backgroundColor.setFill()
            NSBezierPath.fill(dirtyRect)
        }else{
            super.draw(dirtyRect)
        }
    }
}
extension TargetListController: NSTableViewDataSource, NSTableViewDelegate {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return xcodeViewModel.flatList.count
    }
    public func tableView(_ theTableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return tableView(theTableView, isGroupRow: row) ? 24.0 : 18.0
    }
    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let groupRow = GroupRow()
        groupRow.backgroundColor = NSColor.white
        return groupRow
    }
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return xcodeViewModel.flatList[safe: row];
    }
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let item = xcodeViewModel.flatList[safe: row] else { return nil }
        if item is XCProject {
            guard let view = tableView.make(withIdentifier: "HeaderCell", owner: self) as? NSTableCellView else { return nil }
            
            view.textField?.stringValue = item.description
            return view
            
        }else{
            guard let view = tableView.make(withIdentifier: DataCell.identifier, owner: self) as? DataCell else { return nil }
            
            view.textField?.stringValue = item.description
            view.imageView?.image = NSImage.init(contentsOfFile: item.imagePath)
            view.indentationLevel = item is XCProject ? 0 : 1
            return view
        }
        
        
    }
    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        guard let item = xcodeViewModel.flatList[safe: row] else { return false }
        return item is XCTarget
    }
    public func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        guard let item = xcodeViewModel.flatList[safe: row] else { return false }
        return item is XCProject
    }
    public func tableViewSelectionDidChange(_ notification: Notification) {
        
    }
}

