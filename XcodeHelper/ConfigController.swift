//
//  ConfigController.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 7/5/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Cocoa
import CliRunnable
import Yaml
import XcodeHelperCliKit

/*
 Parse the yaml config file when menu is opened or action is triggered
 Update ui based off yaml fields
 When field is modified, save to yaml
 General app prefs can be saved to user defaults
 */

public class ConfigController: NSObject {
    static let configFileName = ".xcodehelper"
    static var instances = [ConfigController]()
    static var sharedConfig: [String: [String: [String]]] = [:] //[Command: [OptionName: [OPTION_VALUE]]]
    static var sourcePath: String?
    
    
    @IBOutlet
    public var control: NSControl? {
        didSet {
            if control == nil,
                let index = ConfigController.instances.index(of: self) {
                ConfigController.instances.remove(at: index)
            }
        }
    }
    
    public override init() {
        super.init()
        ConfigController.instances.append(self)
    }
    public static func reloadConfig(at sourcePath: String) {
        ConfigController.sourcePath = sourcePath
        if let config = loadYaml(at: sourcePath) {
            sharedConfig = config
        }
        for instance in ConfigController.instances {
            //TODO: set the tool tip to be the same as the help info
            instance.updateControl()
        }
    }
    public static func loadYaml(at sourcePath: String) -> [String: [String: [String]]]? {
        let helper = XCHelper()
        let path = URL.init(fileURLWithPath: sourcePath).appendingPathComponent(ConfigController.configFileName).path
        do {
            if let config = try helper.parse(yamlConfigurationPath: path) {
                return config
            }
        }catch let e{
            print(String(describing: e))
        }
        return nil
    }
    public func getControlValue() -> String? {
        if let identifier = control?.identifier?.rawValue {
            let parts = identifier.components(separatedBy: ".")
            if let commandName = parts.first,
                let optionName = parts.last,
                let entry = ConfigController.sharedConfig[commandName],
                let values = entry[optionName] {
                return values.first
            }
        }else{
            print("ConfigController control must have an identifier of the keyPath that you want it to represent.")
        }
        return nil
    }
    public func updateControl() {
        guard let value = getControlValue() else { return }
        //checkbox, textfield, popupbutton
        if control is NSButton {
            updateButton(value)
        }else if control is NSTextField {
            updateTextField(value)
        }else if control is NSPopUpButton {
            updatePopUpButton(value)
        }
    }
    public func updateButton(_ value: String) {
        if let button = control as? NSButton {
            button.state = NSControl.StateValue.init((value as NSString).integerValue)
        }
    }
    public func updateTextField(_ value: String) {
        if let textField = control as? NSTextField {
            textField.stringValue = value
        }
    }
    public func updatePopUpButton(_ value: String) {
        if let popUp = control as? NSPopUpButton {
            if let menuItem = popUp.menu?.item(withTitle: value) {
                popUp.select(menuItem)
            }else{
                popUp.selectItem(at: 0)
            }
        }
    }
    
    @IBAction
    public func saveButtonValue(_ sender: NSButton) {
        saveValue("\(sender.state.rawValue)", forIdentifier: sender.identifier!.rawValue)
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
        ConfigController.save()
    }
    public static func save() {
        guard let currentSourcePath = sourcePath else { return }
        var output = ""
        for (command, entry) in ConfigController.sharedConfig {
            output += "\(command):\n"
            output += entry.sorted(by:{$0.key < $1.key}).flatMap({ (arg: (key: String, value: [String])) in
                let optionName = "  \(arg.key): "
                let optionValue = arg.value.count == 1 ? arg.value[0] : "\n"+arg.value.map({ "    - \($0)" }).joined(separator: "\n")
                return optionValue.count > 0 ? optionName+optionValue : nil
            }).joined(separator: "\n")
            output += "\n"
        }
        try? output.write(to: URL.init(fileURLWithPath: currentSourcePath).appendingPathComponent(ConfigController.configFileName),
                          atomically: false,
                          encoding: .utf8)
    }
}
