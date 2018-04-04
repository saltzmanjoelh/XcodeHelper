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

public struct CommandRunner {
    public static let configFileName = ".xcodehelper"
    public static let logsSubDirectory = ".xcodehelper_logs"
    public let xcodeHelper = XcodeHelper()
    
    public init(){}
    
    public func run(_ command: Command, atSourcePath sourcePath: String) {
        guard let logsDirectory = URL.init(string: sourcePath)?.appendingPathComponent(CommandRunner.logsSubDirectory)
            else { return }
        let configPath = URL(fileURLWithPath: sourcePath).appendingPathComponent(CommandRunner.configFileName).path
        DispatchQueue.global().async {
            do {
                FileManager.default.changeCurrentDirectoryPath(sourcePath)
                let xchelper = XCHelper()
                let results = try xchelper.run(arguments: [sourcePath, //assuming executing binary from sourcePath
                    command.rawValue],
                                               environment: [:],
                                               yamlConfigurationPath: configPath)
                if let uuid = self.xcodeHelper.logger.log("Done", for: command, logsDirectory: logsDirectory) {
                    let log = self.logStringFromProcessResults(results)
                    try self.storeLog(log, inDirectory: logsDirectory, uuid: uuid)
                }
            }catch let e{
                let errorLog = String(describing: e)
                if let errorUuid = self.xcodeHelper.logger.error(errorLog, for: command, logsDirectory: logsDirectory) {
                    try? self.storeLog(errorLog, inDirectory: logsDirectory, uuid: errorUuid)
                }
            }
        }
    }
    func storeLog(_ log: String, inDirectory logsDirectory: URL, uuid: UUID) throws {
        try prepareLogsDirectory(logsDirectory.path)
        try removeOldLogs(logsDirectory.path)
        FileManager.default.createFile(atPath: logsDirectory.appendingPathComponent("\(uuid.uuidString).log").path,
                                       contents: log.data(using: .utf8),
                                       attributes: nil)
    }
    func prepareLogsDirectory(_ logsDirectory: String) throws {
        var directory = ObjCBool(false)
        if FileManager.default.fileExists(atPath: logsDirectory, isDirectory: &directory),
            directory.boolValue == false {
            try FileManager.default.removeItem(atPath: logsDirectory)
        }
        if !FileManager.default.fileExists(atPath: logsDirectory) {
            try FileManager.default.createDirectory(atPath: logsDirectory, withIntermediateDirectories: false, attributes: nil)
        }
    }
    func removeOldLogs(_ logsDirectory: String) throws {
        
    }
    func logStringFromProcessResults(_ processResults: [ProcessResult]) -> String {
        let header: (String) -> (String) = { title in
            return "===================   \(title)   ===================\n"
        }
        var log = ""
        for processResult in processResults {
            //output
            log.append(header("Output"))
            if let output = processResult.output {
                log.append(output)
            }
            //exit code
            log.append("\n"+header("Exit Code"))
            log.append(String(describing: processResult.exitCode))
            log.append("\n")
            //error
            log.append(header("Error"))
            if let error = processResult.error {
                log.append(error)
            }
            log.append("\n\n")
        }
        return log
    }
}
