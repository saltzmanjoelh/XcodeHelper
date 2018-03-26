//
//  StatusMenuController.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/14/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import AppKit
import XcodeHelperKit
import DockerProcess
import XcodeHelperCliKit

//Populates the status menu and handles the commands

@objc
class StatusMenuController: NSObject {
    
    public let statusItem: NSStatusItem
    var windowController: NSWindowController?
    let xcodeHelper = XcodeHelper()
    
    public let xcode: Xcode
    public var document: XCDocumentable?
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
        if let windowController = NSApplication.shared.windows.first?.delegate as? NSWindowController {
            self.windowController = windowController
        }
        super.init()
        if let currentDocument = document {
            refresh(statusItem.menu, currentDocument: currentDocument)
        }
    }
    
    //handle xcodehelper:// urls
    @objc
    func handleGetURL(event: NSAppleEventDescriptor, reply:NSAppleEventDescriptor) {
        if let currentDocument = document ?? xcode.getCurrentDocumentable(using: xcode.currentDocumentScript) {
            refresh(statusItem.menu, currentDocument: currentDocument)
        }
        if let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue {
            print("got urlString \(urlString)")
        }
    }
    func menuNeedsUpdate(_ menu: NSMenu){
        guard let currentDocument = xcode.getCurrentDocumentable(using: xcode.currentDocumentScript),
            shouldRefresh(currentDocument)
            else { return }
        refresh(menu, currentDocument: currentDocument)
    }
    func shouldRefresh(_ currentDocument: XCDocumentable?) -> Bool {
        if [document, currentDocument].compactMap({ $0 != nil }).count == 1 || document!.path != currentDocument!.path{
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
        let currentDates = projects.compactMap({ $0.schemeManagementModificationDate() })
        return projects.compactMap({ $0.modificationDate }) == currentDates
    }
    func refresh(_ menu: NSMenu?, currentDocument: XCDocumentable) {
        guard let menuItem = menu?.items[safe: 1],
            let submenu = menuItem.submenu,
            let menuItems = targetMenuItems(for: currentDocument)
            else { return }
        
        let newTargets = menuItems.compactMap({ $0.representedObject as? XCTarget})
        let oldTargets = submenu.items.compactMap({ $0.representedObject as? XCTarget })
        
        if newTargets != oldTargets { //we only want to update the menu if we have to
            submenu.removeAllItems()
            for menuItem in menuItems {
                submenu.addItem(menuItem)
            }
        }
        self.document = currentDocument
        NotificationCenter.default.post(name: Xcode.DocumentChanged, object: currentDocument)
    }
    func refreshConfig() {
        if let sourcePath = self.document?.getSourcePath() {
            ConfigController.reloadConfig(at: sourcePath)
        }
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
        menu.items.last!.state = NSControl.StateValue.on
        menu.items.last!.target = self
        
        //Manual Targets
        menu.addItem(withTitle: "Manual Target", action: nil, keyEquivalent: "")
        menu.items.last?.submenu = NSMenu()
        if let menuItems = targetMenuItems(for: document), //document was just set during init
            let subMenu = menu.items.last?.submenu {
            subMenu.removeAllItems()
            for menuItem in menuItems {
                subMenu.addItem(menuItem)
            }
        }
        menu.addItem(NSMenuItem.separator())
        
        //Commands
        for command in Command.allCommands {
            menu.addItem(withTitle: command.title,
                         action: #selector(executeCommand(_:)),
                         keyEquivalent: "")
            menu.items.last?.target = self
            menu.items.last?.representedObject = command
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
        autoItem.state = target == nil ? NSControl.StateValue.on : NSControl.StateValue.off
        manualItem.state = target != nil ? NSControl.StateValue.on : NSControl.StateValue.off
        if let submenu = manualItem.submenu {
            for item in submenu.items {
                if let itemTarget = item.representedObject as? XCTarget {
                    item.state = target == itemTarget ? NSControl.StateValue.on : NSControl.StateValue.off
                }
            }
        }
    }
    @objc
    func executeCommand(_ sender: NSMenuItem) {
        guard let sourcePath = getSourcePath(),
            let command = sender.representedObject as? Command
            else { return }
        let configPath = URL(fileURLWithPath: sourcePath).appendingPathComponent(ConfigController.configFileName).path
        DispatchQueue.global().async {
            do {
                FileManager.default.changeCurrentDirectoryPath(sourcePath)
                let xchelper = XCHelper()
                try xchelper.run(arguments: [sourcePath, //assuming executing binary from sourcePath
                                             command.rawValue],
                                 environment: [:],
                                 yamlConfigurationPath: configPath)
                self.xcodeHelper.logger.log("Done", for: command)
            }catch let e{
                self.xcodeHelper.logger.log(String(describing: e), for: nil)
            }
        }
    }

}

// MARK: handle commands
extension StatusMenuController {
    @IBAction
    func preferences(sender: Any){
        NSApplication.shared.activate(ignoringOtherApps: true)
        refreshConfig()
        DispatchQueue.main.async {
            self.windowController?.window?.makeKeyAndOrderFront(nil)
        }
        
    }
    @IBAction
    func quit(sender: Any){
        NSApp.terminate(nil)
    }
    
    @objc func selectTarget(sender: Any) {
        if let menuItem = sender as? NSMenuItem, let target = menuItem.representedObject as? XCTarget {
            self.target = target
        }
        else{
            self.target = nil
        }
    }
    
    func currentPath() -> String? {
        guard let document = xcode.getCurrentDocumentable(using: xcode.currentDocumentScript) else { return nil }
        return document.currentTargetPath()
    }
    func getSourcePath() -> String? {
        return xcode.getCurrentDocumentable(using: xcode.currentDocumentScript)?.getSourcePath()
    }
}
