//
//  StatusMenuController.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/14/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import AppKit

//Populates the status menu and handles the commands

@objc
class StatusMenuController: NSObject {
    
    public let statusItem: NSStatusItem
    let xcode: Xcode
    var document: XCDocumentable?
    var projectModificationDate: NSDate? //if the document is an XCProject, this is the modification date from the scheme management plist
    var target: XCTarget? {
        didSet {
            updateSelectedTarget()
        }
    }
    
    init(statusItem: NSStatusItem, xcode: Xcode) {
        self.statusItem = statusItem
        self.xcode = xcode
        document = xcode.getCurrentDocumentable(using: xcode.currentDocumentScript)
    }
    
    //handle xcodehelper:// urls
    @objc
    func handleGetURL(event: NSAppleEventDescriptor, reply:NSAppleEventDescriptor) {
        refresh(statusItem.menu)
        if let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue {
            print("got urlString \(urlString)")
        }
    }
    func menuNeedsUpdate(_ menu: NSMenu){
        refresh(statusItem.menu)
    }
    func shouldRefresh(_ currentDocument: XCDocumentable?) -> Bool {
        if [document, currentDocument].flatMap({ $0 != nil }).count == 1 || document!.path != currentDocument!.path{
            //either there was a document and there isn't one now, or there wasn't one and there is now
            //or they are different documents
            return true
        }
        
        //if target is NOT nil, it's a manual selection, don't worry about refreshing
        if target != nil {
            return false
        }//otherwise we are on automatic and it's the same document
        
        
        //if it's a workspace of projects or a single project we can look at the management file modification dates
        //this is quicker than getting a list of all projects and comparing them
        if let workspace = currentDocument as? XCWorkspace {
            if let projects = workspace.projects {
                return projectsHaveBeenModified(projects)
            }
            return false
        }
        let project = currentDocument as! XCProject
        return projectsHaveBeenModified([project])
    }
    func projectsHaveBeenModified(_ projects: [XCProject]) -> Bool{
        let currentDates = projects.flatMap({ $0.schemeManagementModificationDate() })
        return projects.flatMap({ $0.modificationDate }) == currentDates
    }
    func refresh(_ menu: NSMenu?) {
        let currentDocument = xcode.getCurrentDocumentable(using: xcode.currentDocumentScript)
        if !shouldRefresh(currentDocument) {
            return
        }
        
        guard let menuItem = menu?.items[safe: 1],
            let submenu = menuItem.submenu,
            let menuItems = targetMenuItems(for: currentDocument)
            else { return }
        
        
        
        let newTargets = menuItems.flatMap({ $0.representedObject as? XCTarget})
        let oldTargets = submenu.items.flatMap({ $0.representedObject as? XCTarget })
        
        if newTargets != oldTargets { //we only want to update the menu if we have to
            submenu.removeAllItems()
            for menuItem in menuItems {
                submenu.addItem(menuItem)
            }
        }
        self.document = currentDocument
    }
    
    func sendNotification(_ title: String, message: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
}
// MARK: prepare the menu
extension StatusMenuController: NSMenuDelegate {
    
    func newStatusMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        
        //Auto Target
        menu.addItem(withTitle: "Automatic Target", action: #selector(StatusMenuController.selectTarget), keyEquivalent: "")
        menu.items.last!.state = NSOnState
        menu.items.last!.target = self
        
        //Manual Targets
        menu.addItem(withTitle: "Manual Target", action: nil, keyEquivalent: "")
        menu.items.last?.submenu = NSMenu()
        if let menuItems = targetMenuItems(for: xcode.getCurrentDocumentable(using: xcode.currentDocumentScript)), let subMenu = menu.items.last?.submenu {
            subMenu.removeAllItems()
            for menuItem in menuItems {
                subMenu.addItem(menuItem)
            }
        }
        menu.addItem(NSMenuItem.separator())
        
        //Commands
        for command in Command.allValues {
            menu.addItem(withTitle: command.rawValue, action: action(for: command), keyEquivalent: "")
            menu.items.last?.target = self
        }
        
        // Prefs and Quit
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Preferences", action: #selector(StatusMenuController.preferences), keyEquivalent: ",")
        menu.items.last?.target = self
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(StatusMenuController.quit), keyEquivalent: "q")
        menu.items.last?.target = self
        return menu
    }

    func targetMenuItems(for document: XCDocumentable?) -> [NSMenuItem]? {
        guard let theDocument = document else { return nil }
        
        var menuItems = [NSMenuItem]()
        let projects = xcode.getProjects(from: theDocument)
        for project in projects {
            menuItems.append(NSMenuItem.separator())
            for target in project.orderedTargets() {
                menuItems.append(NSMenuItem.init(title: target.description, action:  #selector(StatusMenuController.selectTarget), keyEquivalent: ""))
                menuItems.last?.target = self
                menuItems.last?.representedObject = target
                if let imageData = target.imageData() {
                    menuItems.last?.image = NSImage.init(data: imageData)
                    menuItems.last?.image?.size = NSMakeSize(16.0, 16.0)
                }
            }
        }
        return menuItems
    }
    func updateSelectedTarget() {
        guard let menu = statusItem.menu else { return }
        guard let autoItem = menu.items[safe: 0], let manualItem = menu.items[safe: 1] else { return }
        autoItem.state = target == nil ? NSOnState : NSOffState
        manualItem.state = target != nil ? NSOnState : NSOffState
        if let submenu = manualItem.submenu {
            for item in submenu.items {
                if let itemTarget = item.representedObject as? XCTarget {
                    item.state = target == itemTarget ? NSOnState : NSOffState
                }
            }
        }
    }
    
    
    func action(for command: Command) -> Selector {
        switch command {
        case .updateMacOsPackages:
            return #selector(StatusMenuController.updateMacOsPackages)
        case .updateDockerPackages:
            return #selector(StatusMenuController.updateDockerPackages)
        case .buildInDocker:
            return #selector(StatusMenuController.buildInDocker)
        case .symlinkDependencies:
            return #selector(StatusMenuController.symlinkDependencies)
        case .createArchive:
            return #selector(StatusMenuController.createArchive)
        case .createXcarchive:
            return #selector(StatusMenuController.createXCArchive)
        case .uploadArchive:
            return #selector(StatusMenuController.uploadArchive)
        case .gitTag:
            return #selector(StatusMenuController.gitTag)
        }
    }

}

// MARK: handle commands
extension StatusMenuController {
    @IBAction
    func preferences(sender: Any){
        NSApplication.shared().mainWindow?.makeKeyAndOrderFront(nil)
    }
    @IBAction
    func quit(sender: Any){
        NSApp.terminate(nil)
    }
    
    func selectTarget(sender: Any) {
        if let menuItem = sender as? NSMenuItem, let target = menuItem.representedObject as? XCTarget {
            self.target = target
        }
        else{
            self.target = nil
        }
    }
    
    func updateMacOsPackages(){
        print("updateMacOsPackages")
    }
    func updateDockerPackages(){
        print("updateDockerPackages")
    }
    func buildInDocker(){
        print("buildInDocker")
    }
    func symlinkDependencies(){
        
    }
    func createArchive(){
        
    }
    func createXCArchive(){
        
    }
    func uploadArchive(){
        
    }
    func gitTag(){
        
    }
    func createXcarchive(){
        
    }
}
