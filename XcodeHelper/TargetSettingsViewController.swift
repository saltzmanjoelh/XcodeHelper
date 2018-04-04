//
//  TargetSettingsViewController.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 1/21/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import AppKit
import XcodeHelperKit
import XcodeHelperCliKit

class TargetSettingsViewController: NSViewController {
    
    public static let VerboseConfigKey = "VerboseConfigFile"
    var configController = ConfigController()
    
    @IBOutlet
    var majorTagField: NSTextField?
    @IBOutlet
    var minorTagField: NSTextField?
    @IBOutlet
    var patchTagField: NSTextField?
    
    override func viewDidLoad() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: ConfigController.reloadNotification, object: nil)
        refresh()
    }
    @objc func refresh() {
        //static var sharedConfig: [String: [String: [String]]] = [:] //[Command: [OptionName: [OPTION_VALUE]]]
        let xchelper = XCHelper()
        for command in xchelper.cliOptionGroups[0].options {
            guard let commandName = command.keys.first /* update-macos-packages */ else { continue }
            let reqArguments = command.requiredArguments ?? []
            let optionalArguments = command.optionalArguments ?? []
            for option in reqArguments+optionalArguments {
                let optionName = option.keys[1]
                let optionValues = ConfigController.sharedConfig[commandName]?[optionName]
                if let control = view.subview(named: "\(commandName).\(optionName)") as? NSControl {
                    updateControl(control, using: optionValues?.first)
                }
            }
        }
        
        updateGitTagFields(xchelper)
    }
    func updateGitTagFields(_ xchelper: XCHelper) {
        var majorTag = ""
        var minorTag = ""
        var patchTag = ""
        guard var helper = xchelper.xcodeHelpable as? XcodeHelper else { return }
        helper.logger.logLevel = .none
        if let currentSourcePath = ConfigController.sourcePath,
            let gitTag = try? helper.getGitTag(at: currentSourcePath, shouldLog: false) {
            let components = gitTag.components(separatedBy: ".")
            if components.count == 3 {
                majorTag = components[0]
                minorTag = components[1]
                patchTag = components[2]
            }
        }
        majorTagField?.objectValue = majorTag
        minorTagField?.objectValue = minorTag
        patchTagField?.objectValue = patchTag
    }
    public func updateControl(_ control: NSControl, using value: String?) {
        //popupbutton, checkbox, textfield
        if control is NSPopUpButton {
            updatePopUpButton(control, with:value)
        }else if control is NSButton {
            updateButton(control, with: value)
        }else if control is NSTextField {
            updateTextField(control, with: value)
        }
    }
    public func updateButton(_ control: NSControl, with value: String?) {
        if let button = control as? NSButton {
            if let stateValue = value,
                stateValue == "true" || stateValue == "" {
                button.state = NSControl.StateValue.on
            }else{
                button.state = NSControl.StateValue.off
            }
        }
    }
    public func updateTextField(_ control: NSControl, with value: String?) {
        if let textField = control as? NSTextField {
            textField.objectValue = value
        }
    }
    public func updatePopUpButton(_  control: NSControl, with value: String?) {
        if let popUp = control as? NSPopUpButton {
            if let titleValue = value,
                let menuItem = popUp.menu?.item(withTitle: titleValue) {
                popUp.select(menuItem)
            }else{
                popUp.selectItem(at: 0)
            }
        }
    }
    
    @IBAction func saveVerboseConfigOption(_ sender: NSButton) {
        UserDefaults.standard.set(sender.state == .on, forKey: TargetSettingsViewController.VerboseConfigKey)
        saveConfig()
    }
    @IBAction
    public func saveButtonValue(_ sender: NSButton) {
        saveValue(sender.state.rawValue == 1 ? "true" : "false", forIdentifier: sender.identifier!.rawValue)
    }
    @IBAction
    public func saveTextFieldValue(_ sender: NSTextField) {
        saveValue(sender.stringValue, forIdentifier: sender.identifier!.rawValue)
    }
    @IBAction
    public func savePopUpValue(_ sender: NSPopUpButton) {
        saveValue(sender.selectedItem?.title, forIdentifier: sender.identifier!.rawValue)
    }
    public func saveValue(_ value: String?, forIdentifier identifier: String) {
        let parts = identifier.components(separatedBy: ".")
        guard let command = parts.first,
            let optionName = parts.last
            else { return }
        var entry = ConfigController.sharedConfig[command] ?? [String : [String]]()
        if let updatedValue = value {
            entry[optionName] = [updatedValue]
        }else{
            entry[optionName] = []
        }
        ConfigController.sharedConfig[command] = entry
        saveConfig()
    }
    func saveConfig() {
        let config = UserDefaults.standard.bool(forKey: TargetSettingsViewController.VerboseConfigKey) ?
            verboseConfig() :
            ConfigController.sharedConfig
        ConfigController.saveConfig(config)
    }
    func verboseConfig() -> [String: [String: [String]]] {
        var config = ConfigController.sharedConfig
        let xchelper = XCHelper()
        for optionGroup in xchelper.cliOptionGroups {
            for command in optionGroup.options {//updateMacOsPackagesOption
                //"-d", "--chdir", "UPDATE_MACOS_PACKAGES_CHDIR"
                //short, long, env
                var entry = config[command.keys[0]] ?? [:]
                if let requiredArguments = command.requiredArguments {
                    for requiredArgument in requiredArguments {
                        let key = requiredArgument.keys[1]
                        if entry[key] == nil {
                            if requiredArgument.defaultValue == nil {
                                //add the key but comment it out
                                entry["#\(key)"] = []
                            }else{
                                entry[key] = [requiredArgument.defaultValue!]
                            }
                        }
                    }
                }
                if let optionalArguments = command.optionalArguments {
                    for optionalArgument in optionalArguments {
                        let key = optionalArgument.keys[1]
                        if entry[key] == nil {
                            if optionalArgument.defaultValue == nil {
                                //add the key but comment it out
                                entry["#\(key)"] = []
                            }else{
                                entry[key] = [optionalArgument.defaultValue!]
                            }
                        }
                    }
                }
                config[command.keys[0]] = entry
            }
        }
        
        return config
    }
}
