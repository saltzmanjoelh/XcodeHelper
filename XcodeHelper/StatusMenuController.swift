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
import ProcessRunner

//Populates the status menu and handles the commands

@objc
class StatusMenuController: NSObject {
    
    public let statusItem: NSStatusItem
    public let xcodeHelper = XcodeHelper()
    var windowController: NSWindowController?
    var commandRunner: CommandRunner?
    
//    let logger = Logger()
    
    public let xcode: Xcode
    public var document: XCDocumentable?
    var projectModificationDate: NSDate? //if the document is an XCProject, this is the modification date from the scheme management plist
    var target: XCTarget? {
        didSet {
//            updateSelectedTarget()
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
        DispatchQueue.global().async {
            self.commandRunner = CommandRunner()
            DispatchQueue.main.async {
                self.refreshMenu(statusItem.menu, currentDocument: self.document)
            }
        }
//        if let currentDocument = document {
        
//        }
    }
    
    func menuNeedsUpdate(_ menu: NSMenu){
        let currentDocument = xcode.getCurrentDocumentable(using: xcode.currentDocumentScript)
        if targetDidChange(currentDocument) {
            refreshMenu(menu, currentDocument: currentDocument)
        }
        
    }
    //This func name should describe what it's refreshing, manual targets
    func targetDidChange(_ currentDocument: XCDocumentable?) -> Bool {
        if String(describing: document) != String(describing: currentDocument){
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
        if let project = currentDocument as? XCProject {
            return projectsHaveBeenModified([project])
        }
        return false
    }
    func projectsHaveBeenModified(_ projects: [XCProject]) -> Bool{
        let currentDates = projects.compactMap({ $0.schemeManagementModificationDate() })
        return projects.compactMap({ $0.modificationDate }) == currentDates
    }
    @discardableResult
    func refreshMenu(_ menu: NSMenu?, currentDocument: XCDocumentable?) -> NSMenu {
        self.document = currentDocument
        /*if let menuItem = menu?.items[safe: 1],
            let submenu = menuItem.submenu,
            let theDocument = currentDocument,
            let menuItems = targetMenuItems(for: theDocument) {
            //Using shouldRefresh to check this
//            let newTargets = menuItems.compactMap({ $0.representedObject as? XCTarget})
//            let oldTargets = submenu.items.compactMap({ $0.representedObject as? XCTarget })
//            if newTargets != oldTargets { //we only want to update the menu if we have to
                submenu.removeAllItems()
                for menuItem in menuItems {
                    submenu.addItem(menuItem)
                }
//            }
        } else {
            print("Remove all items 111")
            menu?.removeAllItems()
        }*/
        let returnMenu = menu ?? NSMenu()
        returnMenu.delegate = self
        returnMenu.removeAllItems()
        if self.document == nil {
            //If there is no document, remove all items and show "No Projects Are Open"
            returnMenu.addItem(withTitle: "No Projects Are Open", action: nil, keyEquivalent: "")
        }else{
            //Commands
            for command in Command.allCommands {
                returnMenu.addItem(withTitle: command.title,
                                   action: #selector(menuItemClicked(_:)),
                                   keyEquivalent: "")
                returnMenu.items.last?.target = self
                returnMenu.items.last?.representedObject = command
                returnMenu.items.last?.toolTip = command.description
            }
        }
        
        // Prefs and Quit
        returnMenu.addItem(NSMenuItem.separator())
        returnMenu.addItem(withTitle: "Preferences", action: #selector(StatusMenuController.preferences), keyEquivalent: ",")
        returnMenu.items.last?.target = self
        returnMenu.addItem(NSMenuItem.separator())
        returnMenu.addItem(withTitle: "Quit", action: #selector(StatusMenuController.quit), keyEquivalent: "q")
        returnMenu.items.last?.target = self
        NotificationCenter.default.post(name: Xcode.DocumentChanged, object: currentDocument)
        return returnMenu
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
    /*
    func newStatusMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        
        /*//Auto Target
        menu.addItem(withTitle: "Automatic Target", action: #selector(StatusMenuController.selectTarget), keyEquivalent: "")
        menu.items.last!.state = NSControl.StateValue.on
        menu.items.last!.target = self
        
        //Manual Targets
        menu.addItem(withTitle: "Manual Target", action: nil, keyEquivalent: "")
        menu.items.last?.submenu = NSMenu()
        if let menuItems = targetMenuItems(for: document), //document was just set during init
            let subMenu = menu.items.last?.submenu {
            for menuItem in menuItems {
                subMenu.addItem(menuItem)
            }
        }
        menu.addItem(NSMenuItem.separator())*/
        
        //Commands
        for command in Command.allCommands {
            menu.addItem(withTitle: command.title,
                         action: #selector(menuItemClicked(_:)),
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
    }*/

    /*func targetMenuItems(for document: XCDocumentable?) -> [NSMenuItem]? {
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
                }else{
                    print("NO IMAGE?")
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
    }*/
    @objc
    func menuItemClicked(_ sender: NSMenuItem) {
        if let command = sender.representedObject as? Command {
            executeCommand(command)
        }
    }
    public func executeCommand(_ command: Command) {
//        self.xcodeHelper.logger.log("Test", for: command)
        let xpcConnection = NSXPCConnection.init(serviceName: "com.joelsaltzman.xchelperxpc")
        xpcConnection.remoteObjectInterface = NSXPCInterface.init(with: XchelperServiceable.self)
        xpcConnection.exportedObject = self
        xpcConnection.resume()
        if let service = xpcConnection.remoteObjectProxy as? XchelperServiceable {
            service.run(commandIdentifier:  command.cliName){ (result) in
//                print(result)
            }
        }
    }
}

// MARK: handle commands
extension StatusMenuController {
    @IBAction
    func showLogs(_ sender: Any){
//        commandRunner.xcodeHelper.logger.showLogs()
    }
    @IBAction
    func preferences(sender: Any){
        print("Logging: \(UserDefaults.standard.bool(forKey: "XcodeHelperKit.Logging"))")
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
