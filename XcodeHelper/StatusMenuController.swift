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
    public let xcode: Xcode
    public var document: XCDocumentable?
    
    var windowController: NSWindowController?
    var commandRunner: CommandRunner?
    var projectModificationDate: NSDate? //if the document is an XCProject, this is the modification date from the scheme management plist
    var target: XCTarget?
    
    init(statusItem: NSStatusItem, xcode: Xcode) {
        self.statusItem = statusItem
        self.xcode = xcode
        if let windowController = NSApplication.shared.windows.first?.delegate as? NSWindowController {
            self.windowController = windowController
        }
        super.init()
        prepareDocument()
    }
    func hasAutomationPermission() -> Bool {
        if #available(OSX 10.14, *) {
            let eventDescriptor = NSAppleEventDescriptor.init(bundleIdentifier: "com.apple.dt.Xcode")
            let status = AEDeterminePermissionToAutomateTarget(eventDescriptor.aeDesc, typeWildCard, typeWildCard, true)
            return status == noErr
        } else {
            return true
        }
    }
    func prepareDocument() {
        DispatchQueue.global().async {
            if !self.hasAutomationPermission() {
                XcodeHelper.logger = Logger(category: "Authorization")
                XcodeHelper.logger?.errorWithNotification("Xcode Helper isn't authorized to read data from Xcode")
                return
            }
            
            self.document = self.xcode.getCurrentDocumentable(using: self.xcode.currentDocumentScript)
            self.commandRunner = CommandRunner()
            DispatchQueue.main.async {
                self.refreshConfig()
                self.refreshMenu(self.statusItem.menu, currentDocument: self.document)
            }
        }
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
// MARK: NSMenuDelegate
extension StatusMenuController: NSMenuDelegate {
    @objc
    func menuItemClicked(_ sender: NSMenuItem) {
        if let command = sender.representedObject as? Command {
            executeCommand(command)
        }
    }
    public func executeCommand(_ command: Command) {
        let xpcConnection = NSXPCConnection.init(serviceName: "com.joelsaltzman.XcodeHelper.xchelperxpc")
        xpcConnection.remoteObjectInterface = NSXPCInterface.init(with: XchelperServiceable.self)
        xpcConnection.exportedObject = self
        xpcConnection.resume()
        if let service = xpcConnection.remoteObjectProxy as? XchelperServiceable {
            service.run(commandIdentifier:  command.cliName){ (result: Any) in
//                print(result)
//                guard let dictionary = result as? [String: String] else { return }
//                if let error = dictionary["error"]{
//                    XcodeHelper.logger?.errorWithNotification("%@", error)
//                }
            }
        }
    }
}

// MARK: handle commands
extension StatusMenuController {
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
