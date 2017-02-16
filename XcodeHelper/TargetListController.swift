//
//  TargetListController.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 2/4/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import AppKit

class ProjectCell: NSTableCellView {
    static let identifier = "ProjectCell"
    var indentationLevel: CGFloat = 0 {
        didSet {
            self.constraints.filter{
                if let firstItem = $0.firstItem as? NSImageView, let secondItem = $0.secondItem as? ProjectCell {
                    return firstItem == imageView && secondItem == self && $0.firstAttribute == .leading
                }
                return false
            }.first?.constant = 10.0 * indentationLevel
        }
    }
}

class TargetListController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet var tableView: NSTableView?
    var xcode = Xcode()
    var sourceObjects: [Any]?
    
    func prepareSourceObjects() {
        var objects = [Any]()
        if xcode.currentDocument == nil {
            xcode.currentDocument = xcode.getCurrentDocumentable()
        }
        if let document = xcode.currentDocument, let projects = xcode.getProjects(from: document) {
            for project in projects {
                objects.append(project)
                if let orderedTargets = project.orderedTargets() {
                    for target in orderedTargets {
                        objects.append(target)
                    }
                }
                
            }
        }
        sourceObjects = objects
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let objects = sourceObjects {
            return objects.count
        }
        return 0
    }
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return sourceObjects?[safe: row] as? XCProject != nil
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return sourceObjects?[safe: row]
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.make(withIdentifier: ProjectCell.identifier, owner: self) as? ProjectCell,
              let object = sourceObjects?[safe: row] as? CustomStringConvertible else {
            return nil
        }
        cell.indentationLevel = self.tableView(tableView, isGroupRow: row) ? 0 : 1
        cell.textField?.stringValue = String(describing: object)
        return cell
    }
}
