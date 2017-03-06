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

extension TargetListController: NSTableViewDataSource, NSTableViewDelegate {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return xcodeViewModel.flatList.count
    }
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return xcodeViewModel.flatList[safe: row];
    }
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let item = xcodeViewModel.flatList[safe: row] else { return nil }
        guard let view = tableView.make(withIdentifier: DataCell.identifier, owner: self) as? DataCell else { return nil }
        
        view.textField?.stringValue = item.description
        view.imageView?.image = NSImage.init(contentsOfFile: item.imagePath)
        view.indentationLevel = item is XCProject ? 0 : 1
        
        return view
    }
}

extension TargetListController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let project = item as? XCProject else {
            return xcodeViewModel.projects.count
        }
        
        return xcodeViewModel.targets[project] != nil ? xcodeViewModel.targets[project]!.count : 0
    }
    
    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let project = item as? XCProject else {
            return xcodeViewModel.projects[safe: index] as Any
        }
        return xcodeViewModel.targets[project]?[safe: index] as Any
    }
    
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item as? XCProject != nil
    }
    
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let project = item as? XCProject {
            return self.outlineView(outlineView, viewFor: project)
        }else if let target = item as? XCTarget {
            return self.outlineView(outlineView, viewFor: target)
        }
        return nil
    }
    func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        //        let path = NSIndexPath.init(forItem: <#T##Int#>, inSection: <#T##Int#>)
        return true
    }
    func outlineView(_ outlineView: NSOutlineView, shouldShowCellExpansionFor tableColumn: NSTableColumn?, item: Any) -> Bool {
        return false
    }
    func outlineView(_ outlineView: NSOutlineView, viewFor project: XCProject) -> NSView? {
        guard let view = outlineView.make(withIdentifier: "HeaderCell", owner: self) as? NSTableCellView else {
            return nil
        }
        
        view.textField?.stringValue = project.description
        view.imageView?.image = NSImage.init(contentsOfFile: XCProject.defaultImagePath)
        
        return view
    }
    func outlineView(_ outlineView: NSOutlineView, viewFor target: XCTarget) -> NSView? {
        guard let view = outlineView.make(withIdentifier: "DataCell", owner: self) as? NSTableCellView else {
            return nil
        }
        
        view.textField?.stringValue = target.description
        view.imageView?.image = NSImage.init(contentsOfFile: target.imagePath)
        
        return view
    }
}
