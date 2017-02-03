//
//  MenuManager.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/21/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import AppKit

struct MenuManager {
    static func newStatusMenu(with target: StatusMenuDelegate) -> NSMenu {
        let menu = NSMenu()
        menu.delegate = target
        menu.addItem(withTitle: "No Project", action: nil, keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        
        //add each item the commandMap
        for command in Command.allValues {
            menu.addItem(withTitle: command.rawValue, action: action(for: command), keyEquivalent: "")
            menu.items.last?.target = target
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Preferences", action: #selector(StatusMenuDelegate.preferences), keyEquivalent: ",")
        menu.items.last?.target = target
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(StatusMenuDelegate.quit), keyEquivalent: "q")
        menu.items.last?.target = target
        return menu
    }
    static func action(for command: Command) -> Selector {
        switch command {
        case .updateMacOsPackages:
            return #selector(StatusMenuDelegate.updateMacOsPackages)
        case .updateDockerPackages:
            return #selector(StatusMenuDelegate.updateDockerPackages)
        case .buildInDocker:
            return #selector(StatusMenuDelegate.buildInDocker)
        case .symlinkDependencies:
            return #selector(StatusMenuDelegate.symlinkDependencies)
        case .createArchive:
            return #selector(StatusMenuDelegate.createArchive)
        case .createXcarchive:
            return #selector(StatusMenuDelegate.createXCArchive)
        case .uploadArchive:
            return #selector(StatusMenuDelegate.uploadArchive)
        case .gitTag:
            return #selector(StatusMenuDelegate.gitTag)
        }
    }
    
    static func newMenu(with titles: [String]) -> NSMenu {
        let menu = NSMenu()
        for title in titles {
            menu.addItem(withTitle: title, action: nil, keyEquivalent: "")
        }
        return menu
    }
}
