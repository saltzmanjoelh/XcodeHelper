//
//  CommandRunner.swift
//  Helper
//
//  Created by Joel Saltzman on 3/31/18.
//  Copyright © 2018 Joel Saltzman. All rights reserved.
//

import Foundation
import XcodeHelperKit
import XcodeHelperCliKit
import CliRunnable
import ProcessRunner

public class CommandRunner: XchelperServiceable {
    public static let configFileName = ".xcodehelper"
    public let xcodeHelper = XcodeHelper()
    public let xcode = Xcode()
    
    public init(){}
    public func run(commandIdentifier: String, withReply: (Any) -> ()) {
        let command = Command.init(title: "", description: "", cliName: commandIdentifier, envName: "")
        guard let sourcePath = xcode.getCurrentDocumentable(using: xcode.currentDocumentScript)?.getSourcePath(),
            let logsDirectory = URL.init(string: sourcePath)?.appendingPathComponent(XcodeHelper.logsSubDirectory)
            else { return }
        let configPath = URL(fileURLWithPath: sourcePath).appendingPathComponent(CommandRunner.configFileName).path
//        DispatchQueue.global().async {
            do {
                FileManager.default.changeCurrentDirectoryPath(sourcePath)
                let xchelper = XCHelper()
                let processResults = try xchelper.run(arguments: [sourcePath, //assuming executing binary from sourcePath
                                                                  command.cliName],
                                                      environment: [:],
                                                      yamlConfigurationPath: configPath)
                
                if let uuid = self.xcodeHelper.logger.log("Done", for: command) {
                    let log = self.xcodeHelper.logger.logStringFromProcessResults(processResults)
                    try self.xcodeHelper.logger.storeLog(log, inDirectory: logsDirectory, uuid: uuid)
                }
                var results = [String: String]()
                if let output = processResults.first?.output {
                    results["output"] = output
                }
                if let error = processResults.first?.error {
                    results["error"] = error
                }
                if let exitCode = processResults.first?.exitCode {
                    results["exitCode"] = "\(exitCode)"
                }
                withReply(results)
            }catch let e{
                let errorLog = String(describing: e)
                if let errorUuid = self.xcodeHelper.logger.error(errorLog, for: command) {
                    _ = try? self.xcodeHelper.logger.storeLog(errorLog, inDirectory: logsDirectory, uuid: errorUuid)
                }
                withReply(errorLog)
            }
//        }
    }
    
}
