//
//  SettingsViewController.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/21/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import AppKit


class SettingsViewController: NSViewController {
    
    @IBOutlet var pathLabel: NSTextField?
    @IBOutlet var commandsPopUp: NSPopUpButton?
    @IBOutlet var containerView: NSView?
    @IBOutlet var projectListController: TargetListController?
    
    var xcode = Xcode()
    
    override func viewDidLoad() {
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else {
            return
        }
        preparePathLabel()
        if let popUp = commandsPopUp {
            prepareCommandsPopUp(popUp)
            commandPopUpChanged(sender: popUp)
        }
    }
    func prepareTargetsPopUp() {
        targetsPopUp?.removeAllItems()
        guard let targets = xcode.getCurrentDocumentable()?.orderedTargets() else {
            return
        }
        for target in targets {
            targetsPopUp?.addItem(withTitle: target.name)
        }
    }
    func preparePathLabel() {
        if let path = xcode.getCurrentDocumentable()?.path {
            pathLabel?.stringValue = path
        }else{
            pathLabel?.stringValue = ""
        }
    }
    
    func prepareCommandsPopUp(_ popUp: NSPopUpButton) {
        popUp.addItems(withTitles: Command.allValues.filter({ $0 != .symlinkDependencies }).map{ $0.rawValue } )
        popUp.menu?.items.forEach{
            $0.target = self
            $0.action = #selector(SettingsViewController.commandPopUpChanged)
        }
        popUp.target = self
        popUp.action = #selector(SettingsViewController.commandPopUpChanged)
    }
    
}

extension SettingsViewController: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu){
        //add the current project
        guard let menuItem = menu.items.first else {
            return
        }
        prepareTargetsPopUp()
    }
}
