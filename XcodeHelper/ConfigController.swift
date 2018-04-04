//
//  ConfigController.swift
//  XcodeHelper
//
//  Created by Joel Saltzman on 7/5/17.
//  Copyright © 2017 Joel Saltzman. All rights reserved.
//

import Foundation
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
    static let reloadNotification = Notification.Name.init("reloadConfig")
    static var sharedConfig: [String: [String: [String]]] = [:] //[Command: [OptionName: [OPTION_VALUE]]]
    public static var sourcePath: String?
    
    public static func reloadConfig(at sourcePath: String) {
        ConfigController.sourcePath = sourcePath
        if let config = loadYaml(at: sourcePath) {
            sharedConfig = config
        }
        NotificationCenter.default.post(Notification.init(name: ConfigController.reloadNotification, object: nil))
//        TargetSettingsViewController refresh will iterate all views and refresh their values
//        TargetSettingsViewController can have it's own ConfigController in a xib with outlets for the controls to save their values
//        Custom controls like git tag will have custom function in TargetSettingsViewController
    }
    public static func loadYaml(at sourcePath: String) -> [String: [String: [String]]]? {
        let helper = XCHelper()
        let path = URL.init(fileURLWithPath: sourcePath).appendingPathComponent(CommandRunner.configFileName).path
        do {
            if let config = try helper.parse(yamlConfigurationPath: path) {
                return config
            }
        }catch let e{
            print(String(describing: e))
        }
        return nil
    }
    public static func saveConfig(_ config: [String: [String: [String]]]) {
        guard let currentSourcePath = sourcePath else { return }
        var output = ""
        let xchelper = XCHelper()
        guard let commandGroup = xchelper.cliOptionGroups.first else { return }
        for option in commandGroup.options {
            let command = option.keys[0]
            guard let entry = config[command] else { continue }
            var commandHasValues = false
            let entryStrings = entry.sorted(by:{$0.key < $1.key}).compactMap { (arg: (key: String, value: [String])) -> String? in
                let optionName = "  \(arg.key): "
                let optionValue = arg.value.count == 1 ? arg.value[0] : arg.value.map({ "\n    - \($0)" }).joined(separator: "")
                if !commandHasValues {
                    commandHasValues = optionValue.count > 0
                }
                return optionName+optionValue
            }
            let verbose = UserDefaults.standard.bool(forKey: TargetSettingsViewController.VerboseConfigKey)
            let entryOutput = verbose ? entryStrings.joined(separator: "\n") : entryStrings.filter({ !$0.hasPrefix("#")}).joined(separator: "\n")
            if commandHasValues {
                output += "\(command):\n\(entryOutput)\n"
            }else if verbose {
                //There are no valid values for the command, comment it out
                output += "#\(command):\n\(entryOutput)\n"
            }
        }
        let url = URL.init(fileURLWithPath: currentSourcePath).appendingPathComponent(CommandRunner.configFileName)
        try? output.write(to: url, atomically: false, encoding: .utf8)
    }
}
