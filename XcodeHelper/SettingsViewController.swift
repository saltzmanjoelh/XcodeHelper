//
//  SettingsViewController.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/21/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import AppKit


class SettingsViewController: NSViewController {
    
    @IBOutlet var targetsPopUp: NSPopUpButton?
    @IBOutlet var pathLabel: NSTextField?
    @IBOutlet var commandsPopUp: NSPopUpButton?
    @IBOutlet var containerView: NSView?
    @IBOutlet var projectListController: TargetListController?
    
    var xcode = Xcode()
    
    override func viewDidLoad() {
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else {
            return
        }
        if let document = xcode.getCurrentDocumentable() {
            xcode.currentDocument = document
        }
        prepareTargetsPopUp()
        preparePathLabel()
        if let popUp = commandsPopUp {
            prepareCommandsPopUp(popUp)
            commandPopUpChanged(sender: popUp)
        }
    }
    func prepareTargetsPopUp() {
        targetsPopUp?.removeAllItems()
        guard let targets = xcode.currentDocument?.orderedTargets() else {
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
    
    @IBAction
    func commandPopUpChanged(sender: Any){
        if let menuItem = sender as? NSMenuItem {
            performSwap(menuItem: menuItem)
        }
        else if let popUp = sender as? NSPopUpButton, let menuItem = popUp.selectedItem {
            performSwap(menuItem: menuItem)
        }
    }
    
    func performSwap(menuItem: NSMenuItem){
        guard let childViewController = storyboard?.instantiateController(withIdentifier: menuItem.title) as? NSViewController else {
            return
        }
        //remove existing child
        while childViewControllers.count > 0 {
            childViewControllers.first?.view.removeFromSuperview()
            removeChildViewController(at: 0)
        }
        
        prepare(childViewController: childViewController)
        
        //add new child
        if let container = containerView {
            addChildViewController(childViewController)
            container.addSubview(childViewController.view)
            childViewController.view.frame = container.bounds
            childViewController.view.translatesAutoresizingMaskIntoConstraints = false
            container.addConstraint(NSLayoutConstraint.init(item: container, attribute: .top, relatedBy: .equal, toItem: childViewController.view, attribute: .top, multiplier: 1.0, constant: 0))
            container.addConstraint(NSLayoutConstraint.init(item: container, attribute: .bottom, relatedBy: .equal, toItem: childViewController.view, attribute: .bottom, multiplier: 1.0, constant: 0))
            container.addConstraint(NSLayoutConstraint.init(item: container, attribute: .left, relatedBy: .equal, toItem: childViewController.view, attribute: .left, multiplier: 1.0, constant: 0))
            container.addConstraint(NSLayoutConstraint.init(item: container, attribute: .right, relatedBy: .equal, toItem: childViewController.view, attribute: .right, multiplier: 1.0, constant: 0))
        }
    }
    
    func prepare(childViewController: NSViewController){
        guard let identifier = childViewController.identifier, let command = Command(rawValue: identifier) else {
            return
        }
        
        //get a list of all keys available from xchelper.cliOptionGroups
        //save in the form [ProjectIdentifier: [key:value]
        //execute xchelper.run( [key="value"]
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
